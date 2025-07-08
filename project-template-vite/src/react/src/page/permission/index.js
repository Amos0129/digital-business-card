import { useState, useEffect, useRef } from 'react'
import { useSuccessToast } from 'component/toast'
import PermissionItemLayout from 'page/permission/item-layout'
import PermissionAddTab from 'page/permission/tab-add'
import PermissionEditTab from 'page/permission/tab-edit'
import { privClient } from 'utils/rest-client'

export default () => {
  const layoutRef = useRef(null)
  const [currentTab, setCurrentTab] = useState(true)
  const [options, setOptions] = useState([])
  const successToast = useSuccessToast()

  useEffect(() => {
    if (layoutRef.current) {
      layoutRef.current.reset()
    }
  }, [currentTab])

  async function addPermission(permissionName) {
    const body = {
      name: permissionName,
      ...layoutRef.current.getEnabledList()
    }

    await privClient.post(body, 'permission')

    successToast('新增成功')

    switchTab(true)
  }

  async function editPermission(permissionId, permissionName) {
    const body = {
      id: permissionId,
      name: permissionName,
      ...layoutRef.current.getEnabledList()
    }

    await privClient.put(body, 'permission', permissionId)

    successToast('修改成功')

    layoutRef.current.reset()
  }

  function switchTab(bool) {
    setCurrentTab(bool)
  }

  return (
    <div className='p-3 border border-secondary rounded'>
      <div className='btn-group' role='group'>
        <button className={`btn btn-secondary ${currentTab ? 'active' : ''}`} onClick={() => switchTab(true)}>
          編輯權限
        </button>
        <button className={`btn btn-secondary ${!currentTab ? 'active' : ''}`} onClick={() => switchTab(false)}>
          新增權限
        </button>
      </div>
      <hr />
      {currentTab ? (
        <PermissionEditTab
          editCallback={editPermission}
          setOptionsFunc={setOptions}
          concatCallback={() => layoutRef.current.reset()}
        />
      ) : (
        <PermissionAddTab saveCallback={addPermission} />
      )}

      <PermissionItemLayout ref={layoutRef} optionSettings={options} />
    </div>
  )
}
