import { useState, useEffect } from 'react'
import { jsonCallBack, required, invalid, isEmptyObj, requireAll } from 'utils/forms'
import ButtonBlock from 'component/button-block'
import { STATUS_MAP, MEMBER_ROUTE } from 'page/member/config'
import { useParams, useNavigate } from 'react-router'
import { privClient } from 'utils/rest-client'
import { useSuccessToast } from 'component/toast'
import ModalWhisper from 'page/member/modal-whisper'

export default () => {
  const [member, setMember] = useState({
    account: '',
    name: '',
    status: '',
    permissionId: ''
  })
  const [alert, setAlert] = useState({ name: '' })
  const memberId = useParams().memberId
  const successToast = useSuccessToast()
  const navigate = useNavigate()
  const [modal, setModal] = useState(false)
  const [permissionOptions, setPermissionOptions] = useState([])

  useEffect(() => {
    async function init() {
      const { data: currentMember } = await privClient.get({}, 'member', memberId)
      const { data: options } = await privClient.get({}, 'permissions')

      setMember(currentMember)

      setPermissionOptions(options)
    }
    init()
  }, [])

  function handleAlert(event) {
    const dom = event.target

    setAlert((prev) => ({ ...prev, [dom.name]: required(dom.value) }))
  }

  function handleUpdate() {
    const alertClone = requireAll(member, alert)

    setAlert(alertClone)

    if (isEmptyObj(alertClone)) {
      update()
    }
  }

  async function update() {
    await privClient.put(member, 'member', memberId)

    successToast('修改成功')

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
              className='form-control-plaintext c-default'
              id='account'
              type='text'
              name='account'
              maxLength='50'
              disabled
              defaultValue={member.account}
            />
          </div>

          <div className='col-6 d-flex align-items-end mb-3'>
            <button className='btn btn-outline-secondary' onClick={() => setModal(true)}>
              變更密碼
            </button>
          </div>

          <div className='col-6 mb-3'>
            <label className='form-label' htmlFor='name'>
              名稱
            </label>
            <input
              className={`form-control ${invalid(alert.name)}`}
              id='name'
              type='text'
              name='name'
              maxLength='50'
              placeholder='必填'
              value={member.name}
              onChange={jsonCallBack(setMember)}
              onBlur={handleAlert}
            />
            <div className='invalid-feedback'>{alert.name}</div>
          </div>

          <div className='col-6 mb-3'>
            <label className='form-label' htmlFor='status'>
              狀態
            </label>
            <select
              className='form-select'
              id='status'
              name='status'
              value={member.status}
              onChange={jsonCallBack(setMember)}
            >
              {Object.keys(STATUS_MAP).map((jian, index) => (
                <option value={jian} key={index}>
                  {STATUS_MAP[jian]}
                </option>
              ))}
            </select>
          </div>

          <div className='col-6 mb-3'>
            <label className='form-label' htmlFor='permissionId'>
              權限
            </label>
            <select
              className='form-select'
              id='permissionId'
              name='permissionId'
              value={member.permissionId}
              onChange={jsonCallBack(setMember)}
            >
              {permissionOptions.map((option, index) => (
                <option value={option.id} key={index}>
                  {option.name}
                </option>
              ))}
            </select>
          </div>
        </div>

        <ButtonBlock className='w-100 btn btn-outline-primary' onClick={handleUpdate}>
          修改
        </ButtonBlock>
      </div>
      <ModalWhisper memberId={memberId} account={member.account} state={[modal, setModal]} />
    </div>
  )
}
