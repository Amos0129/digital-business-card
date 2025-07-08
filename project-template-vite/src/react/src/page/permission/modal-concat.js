import { useCallback, useState } from 'react'
import { privClient } from 'utils/rest-client'
import { useSuccessToast } from 'component/toast'
import ButtonBlock from 'component/button-block'
import { ModalDialog } from 'component/modal-dialog'

export default ({ target = { id: '', name: '' }, toggleState, onConcat = () => {} }) => {
  const [permissionOptions, setPermissionOptions] = useState([])
  const [selectedOption, setSelectedOption] = useState({ id: '', name: '' })
  const [toggle, setToggle] = toggleState
  const successToast = useSuccessToast()

  const fetchPermissionOptions = useCallback(async () => {
    const { data } = await privClient.get({ ignoreId: target.id }, 'permissions')

    setPermissionOptions(data)
  }, [target.id])

  function handleModalClose() {
    setPermissionOptions([])
  }

  function onSelected(selectedId) {
    const currentOption = permissionOptions.filter((option) => option.id === parseInt(selectedId))[0]

    setSelectedOption({ ...currentOption })
  }

  async function handleConcatPermission() {
    await privClient.delete({ srcId: target.id, destId: selectedOption.id }, 'permission')

    onConcat()

    successToast(`已成功將 ${target.name} 合併至 ${selectedOption.name}`)

    handleCancel()
  }

  function handleCancel() {
    setToggle(false)
  }

  return (
    <ModalDialog visible={toggle} centered backdrop onOpen={fetchPermissionOptions} onClose={handleModalClose}>
      <>
        <div className='modal-header'>請選擇欲合併權限</div>
        <div className='modal-body'>
          <div className='p-3 bg-light'>
            <select
              className='form-select'
              value={selectedOption.id}
              onChange={(event) => onSelected(event.target.value)}
            >
              <option value=''>請選擇</option>
              {permissionOptions.map((permission, index) => (
                <option value={permission.id} key={index}>
                  {permission.name}
                </option>
              ))}
            </select>
          </div>
        </div>
        <div className='modal-footer'>
          <button className='btn btn-outline-secondary' onClick={handleCancel}>
            取消
          </button>
          <ButtonBlock className='btn btn-outline-success' spinner='success' onClick={handleConcatPermission}>
            確認
          </ButtonBlock>
        </div>
      </>
    </ModalDialog>
  )
}
