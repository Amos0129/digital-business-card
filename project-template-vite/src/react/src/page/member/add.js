import { useState, useEffect } from 'react'
import { jsonCallBack, required, invalid, isEmptyObj, requireAll, EMAIL_FORMAT } from 'utils/forms'
import ButtonBlock from 'component/button-block'
import { pubClient, privClient } from 'utils/rest-client'
import { useSuccessToast } from 'component/toast'
import { useNavigate } from 'react-router'
import { MEMBER_ROUTE, WHISPER_FORMAT } from 'page/member/config'
import { rsa } from 'utils/ciphers'
import useAsyncEventQueue from 'component/async-event-queue'
import useStateRef from 'component/state-ref'

const STRUCTURE = {
  account: '',
  whisper: '',
  reWhisper: '',
  name: '',
  permissionId: ''
}

export default () => {
  const [member, setMember] = useState({ ...STRUCTURE })
  const [alertRef, alert, setAlert] = useStateRef({ ...STRUCTURE })
  const [permissionOptions, setPermissionOptions] = useState([])
  const succcessToast = useSuccessToast()
  const navigate = useNavigate()
  const [handleFocus, handleBlur, awaitAllEvent] = useAsyncEventQueue()

  useEffect(() => {
    async function initOptions() {
      const { data } = await privClient.get({}, 'permissions')

      setPermissionOptions(data)
    }

    initOptions()
  }, [])

  function handleAlert(event) {
    const dom = event.target

    setAlert((prev) => ({ ...prev, [dom.name]: required(dom.value) }))
  }

  async function handleAccount(dom) {
    const val = dom.value

    let msg = required(val)

    if (!msg) {
      const { data } = await privClient.get({ account: val }, 'member')

      msg = data ? '帳號已存在' : EMAIL_FORMAT.regex.test(dom.value) ? '' : EMAIL_FORMAT.msg
    }

    setAlert((prev) => ({ ...prev, account: msg }))
  }

  function handleWhisper(event) {
    const dom = event.target
    const anotherDomName = dom.name === 'whisper' ? 'reWhisper' : 'whisper'

    setAlert((prev) => {
      const compareWhisper =
        dom.value && member[anotherDomName] && dom.value !== member[anotherDomName] ? '密碼不一致' : ''
      const msg =
        required(dom.value) || (WHISPER_FORMAT.regex.test(dom.value) ? '' : WHISPER_FORMAT.msg) || compareWhisper
      const anotherAlert =
        !prev[anotherDomName] || prev[anotherDomName] === '密碼不一致' ? compareWhisper : prev[anotherDomName]
      return { ...prev, [dom.name]: msg, [anotherDomName]: anotherAlert }
    })
  }

  function handlePermission(event) {
    const dom = event.target

    setMember((prev) => ({ ...prev, [dom.name]: dom.value }))

    handleAlert(event)
  }

  async function handleCreate() {
    await awaitAllEvent()

    const alertClone = requireAll(member, alertRef.current)

    setAlert(alertClone)

    if (isEmptyObj(alertClone)) {
      await create()
    }
  }

  async function create() {
    const { data: pubKey } = await pubClient.get({ account: member.account }, 'steel')
    const encodeWhisper = await rsa.encrypt(pubKey, member.whisper)

    const dataBody = {
      account: member.account,
      name: member.name,
      armour: encodeWhisper,
      permissionId: member.permissionId
    }

    await privClient.post(dataBody, 'member')

    succcessToast('帳號已建立')

    navigate(MEMBER_ROUTE.path)
  }

  return (
    <div className='p-3 border border-secondary rounded'>
      <div className='container'>
        <div className='row'>
          <div className='col-6 mb-3'>
            <label className='form-label' htmlFor='account'>
              帳號
            </label>
            <input
              className={`form-control ${invalid(alert.account)}`}
              id='account'
              type='text'
              name='account'
              maxLength='50'
              placeholder='必填'
              onChange={jsonCallBack(setMember)}
              onBlur={handleBlur}
              onFocus={handleFocus(handleAccount)}
            />
            <div className='invalid-feedback'>{alert.account}</div>
          </div>

          <div className='col-6 mb-3'>
            <label className='form-label' htmlFor='whisper'>
              密碼
            </label>
            <input
              className={`form-control ${invalid(alert.whisper)}`}
              id='whisper'
              type='password'
              name='whisper'
              maxLength='50'
              placeholder='必填'
              onChange={jsonCallBack(setMember)}
              onBlur={handleWhisper}
            />
            <div className='invalid-feedback'>{alert.whisper}</div>
          </div>

          <div className='col-6 mb-3'>
            <label className='form-label' htmlFor='name'>
              姓名
            </label>
            <input
              className={`form-control ${invalid(alert.name)}`}
              id='name'
              type='text'
              name='name'
              maxLength='50'
              placeholder='必填'
              onChange={jsonCallBack(setMember)}
              onBlur={handleAlert}
            />
            <div className='invalid-feedback'>{alert.name}</div>
          </div>

          <div className='col-6 mb-3'>
            <label className='form-label' htmlFor='reWhisper'>
              確認密碼
            </label>
            <input
              className={`form-control ${invalid(alert.reWhisper)}`}
              id='reWhisper'
              type='password'
              name='reWhisper'
              maxLength='50'
              placeholder='必填'
              onChange={jsonCallBack(setMember)}
              onBlur={handleWhisper}
            />
            <div className='invalid-feedback'>{alert.reWhisper}</div>
          </div>

          <div className='col-6 mb-3'>
            <label className='form-label' htmlFor='permissionId'>
              權限
            </label>
            <select
              className={`form-select ${invalid(alert.permissionId)}`}
              id='permissionId'
              name='permissionId'
              onChange={handlePermission}
            >
              <option value=''>請選擇</option>
              {permissionOptions.map((option, index) => (
                <option value={option.id} key={index}>
                  {option.name}
                </option>
              ))}
            </select>
            <div className='invalid-feedback'>{alert.permissionId}</div>
          </div>
        </div>
        <ButtonBlock className='w-100 btn btn-outline-primary' onClick={handleCreate}>
          建立
        </ButtonBlock>
      </div>
    </div>
  )
}
