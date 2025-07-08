import { useState, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import { useErrorToast, useSuccessToast } from 'component/toast'
import { jsonCallBack, pressEnterCallback, isNotEmptyObj } from 'utils/forms'
import { pubClient } from 'utils/rest-client'
import { rsa } from 'utils/ciphers'
import { useMemberInfo } from 'reducer/member-info'
import { usePermissions } from 'reducer/permissions'
import ButtonBlock from 'component/button-block'
import { HOME_ROUTE } from 'page/home/config'

export default () => {
  const navigate = useNavigate()
  const buttonRef = useRef(null)
  const successToast = useSuccessToast()
  const errorToast = useErrorToast()
  const setMemberInfo = useMemberInfo()[1]
  const setPermissions = usePermissions()[1]
  const [loginInfo, setLoginInfo] = useState({
    account: '',
    whisper: ''
  })

  const errorCode = {
    1: '帳號或密碼有誤',
    2: '近期嘗試次數過多，請15分鐘後再試',
    3: '您所輸入的帳號被停用',
    4: '您所輸入的帳號尚未啟用'
  }

  async function login() {
    if (!isNotEmptyObj(loginInfo)) {
      errorToast('請輸入帳號及密碼')
    } else {
      const { data: pubKey } = await pubClient.get({ account: loginInfo.account }, 'steel')
      const encodedWhisper = await rsa.encrypt(pubKey, loginInfo.whisper)

      try {
        const { data } = await pubClient.post({ account: loginInfo.account, armour: encodedWhisper }, 'login')
        setMemberInfo(data.userInfo)
        setPermissions(data.permission)
        successToast('登入成功')
        navigate(HOME_ROUTE.path)
      } catch (error) {
        const { response } = error
        if (response && response.status === 400) {
          errorToast(errorCode[response.data])
        }
      }
    }
  }

  return (
    <div className='login-bg'>
      <div className='container'>
        <form>
          <h1>TITLE here</h1>
          <div className='mb-3'>
            <label className='form-label' htmlFor='account'>
              帳號
            </label>
            <input
              className='form-control'
              type='text'
              name='account'
              id='account'
              onChange={jsonCallBack(setLoginInfo)}
              autoFocus
              autoComplete='account'
            />
          </div>
          <div className='mb-3'>
            <label className='form-label' htmlFor='whisper'>
              密碼
            </label>
            <input
              className='form-control'
              type='password'
              name='whisper'
              id='whisper'
              onKeyUp={pressEnterCallback(() => buttonRef.current.buttonBlockCallback())}
              onChange={jsonCallBack(setLoginInfo)}
              autoComplete='off'
            />
          </div>
        </form>
        <ButtonBlock ref={buttonRef} className='btn btn-outline-primary w-100' onClick={login}>
          登入
        </ButtonBlock>
      </div>
    </div>
  )
}
