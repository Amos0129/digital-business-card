import { useState, useRef } from 'react'
import { required, invalid, textCallBack, pressEnterCallback } from 'utils/forms'
import { privClient } from 'utils/rest-client'
import ButtonBlock from 'component/button-block'

export default ({ saveCallback }) => {
  const [permissionName, setPermissionName] = useState('')
  const [alertName, setAlertName] = useState('')
  const buttonRef = useRef(null)

  async function checkAlertMsg() {
    let alertMsg = required(permissionName, '必填')

    if (!alertMsg) {
      const { data } = await privClient.get({ name: permissionName }, 'permission', 'exist')

      alertMsg = data ? '權限名稱已重複' : ''
    }

    return alertMsg
  }

  async function blurAlert() {
    setAlertName(await checkAlertMsg())
  }

  async function createPermission() {
    const alertMsg = await checkAlertMsg()

    if (!alertMsg) {
      saveCallback(permissionName)
    }

    setAlertName(alertMsg)
  }

  return (
    <div className='row mb-3'>
      <div className='col-10'>
        <input
          name='name'
          type='text'
          className={`form-control w-50 ${invalid(alertName)}`}
          maxLength={25}
          placeholder='請輸入權限名稱'
          onChange={textCallBack(setPermissionName)}
          onBlur={blurAlert}
          onKeyUp={pressEnterCallback(() => buttonRef.current.buttonBlockCallback())}
        />
        <div className='invalid-feedback'>{alertName}</div>
      </div>
      <div className='col-2 text-end'>
        <ButtonBlock className='btn btn-outline-primary' onClick={createPermission} ref={buttonRef}>
          新增
        </ButtonBlock>
      </div>
    </div>
  )
}
