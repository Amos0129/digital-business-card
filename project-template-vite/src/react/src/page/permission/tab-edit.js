import { useState, useEffect, useRef } from 'react'
import { required, invalid, jsonCallBack, pressEnterCallback } from 'utils/forms'
import { privClient } from 'utils/rest-client'
import ConcatModal from 'page/permission/modal-concat'
import ButtonBlock from 'component/button-block'

export default ({ editCallback, setOptionsFunc, concatCallback }) => {
  const [alertName, setAlertName] = useState('')
  const [permission, setPermission] = useState({ id: '', name: '' })
  const [permissionOptions, setPermissionOptions] = useState([])
  const [modal, setModal] = useState(false)
  const buttonRef = useRef(null)

  useEffect(() => {
    initOptions()
  }, [])

  async function initOptions() {
    const { data } = await privClient.get({}, 'permissions')

    setPermissionOptions(data)
  }

  async function checkAlertMsg() {
    let alertMsg = required(permission.name, '必填')

    if (!alertMsg) {
      const { data } = await privClient.get({ name: permission.name, ignoreId: permission.id }, 'permission', 'exist')

      alertMsg = data ? '權限名稱已重複' : ''
    }

    return alertMsg
  }

  async function blurAlert() {
    setAlertName(await checkAlertMsg())
  }

  async function getSelectedPermission(permissionId) {
    if (permissionId) {
      const currentOptions = permissionOptions.filter((option) => option.id === parseInt(permissionId))[0]

      const { data } = await privClient.get({}, 'permission', permissionId)

      setAlertName('')

      setPermission({ id: currentOptions.id, name: currentOptions.name })

      setOptionsFunc({ page: data.page, feature: data.feature })
    } else {
      setPermission({ id: '', name: '' })
      setOptionsFunc({ page: [], feature: [] })
    }
  }

  async function editPermission() {
    const alertMsg = await checkAlertMsg()

    if (!alertMsg) {
      await editCallback(permission.id, permission.name)

      setPermission({ id: '', name: '' })

      initOptions()
    } else {
      setAlertName(alertMsg)
    }
  }

  function handleConcat() {
    initOptions()

    concatCallback()

    setPermission({ id: '', name: '' })
  }

  return (
    <>
      <div className='row mb-3'>
        <div className='col-6'>
          <select
            className='form-select'
            name='id'
            value={permission.id}
            onChange={(event) => getSelectedPermission(event.target.value)}
          >
            <option value=''>請選擇</option>
            {permissionOptions.map((option, index) => (
              <option value={option.id} key={index}>
                {option.name}
              </option>
            ))}
          </select>
        </div>

        {permission.id && (
          <>
            <div className='w-100 mb-3' />

            <div className='col-6'>
              <input
                name='name'
                type='text'
                className={`form-control ${invalid(alertName)}`}
                maxLength={25}
                placeholder='請輸入權限名稱'
                value={permission.name}
                onBlur={blurAlert}
                onChange={jsonCallBack(setPermission)}
                onKeyUp={pressEnterCallback(() => buttonRef.current.buttonBlockCallback())}
              />
              <div className='invalid-feedback'>{alertName}</div>
            </div>

            <div className='col-6 text-end'>
              <ButtonBlock className='btn btn-outline-primary me-2' onClick={editPermission} ref={buttonRef}>
                修改
              </ButtonBlock>
              <button className='btn btn-outline-danger' onClick={() => setModal(true)}>
                合併並刪除
              </button>
            </div>
          </>
        )}
      </div>

      <ConcatModal target={permission} toggleState={[modal, setModal]} onConcat={handleConcat} />
    </>
  )
}
