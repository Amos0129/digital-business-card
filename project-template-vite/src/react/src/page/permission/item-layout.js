import { useEffect, useState, useImperativeHandle, forwardRef } from 'react'
import { PERMISSION_PACK } from 'config/permission'
import { MENU_PACK } from 'config/menu'

export default forwardRef(({ optionSettings = { page: [], feature: [] } }, ref) => {
  const [permissions, setPermissions] = useState([])
  const [ready, setReady] = useState(false)

  useEffect(() => {
    if (ready) {
      const permissionItems = defaultPermissionItems().map((permission) => ({
        ...permission,
        items: permission.items.map((item) => {
          item.top.enabled = optionSettings.page.some((page) => page.name === `${item.top.name}::${item.top.path}`)

          item.sub = item.sub.map((sub) => ({
            ...sub,
            enabled:
              sub.type === 'page'
                ? optionSettings.page.some((page) => page.name === `${sub.name}::${sub.value}`)
                : optionSettings.feature.some((feature) => feature.name === `${sub.name}::${sub.value}`)
          }))
          return item
        })
      }))

      setPermissions(permissionItems)
    }

    setReady(true)
  }, [optionSettings])

  useImperativeHandle(ref, () => ({
    getEnabledList: getEnabledList,
    reset: () => {
      const permissionItems = defaultPermissionItems()

      setPermissions(permissionItems)
    }
  }))

  function defaultPermissionItems() {
    const permissionWithOption = [...PERMISSION_PACK].map((permission) => ({
      top: { ...permission.top, enabled: false },
      sub: [...permission.sub].map((sub) => ({ ...sub, enabled: false }))
    }))

    return [...MENU_PACK].map((menu) => ({
      name: menu.name,
      items: [...menu.items].reduce((array, item) => {
        const filter = permissionWithOption.filter((permission) => permission.top.name === item.name)

        if (filter.length) {
          array.push(filter[0])
        }

        return array
      }, [])
    }))
  }

  function selectedElement(collect, mainIndex, topIndex) {
    return collect[mainIndex].items[topIndex]
  }

  function topEnabledCallback(mainIndex, topIndex) {
    setPermissions((prev) => {
      const current = selectedElement(prev, mainIndex, topIndex)

      const toggle = !current.top.enabled
      current.top.enabled = toggle
      if (!toggle) {
        current.sub.forEach((sub) => {
          sub.enabled = false
        })
      }
      return [...prev]
    })
  }

  function subEnabledCallback(mainIndex, topIndex, subIndex) {
    setPermissions((prev) => {
      const current = selectedElement(prev, mainIndex, topIndex)

      current.sub[subIndex].enabled = !current.sub[subIndex].enabled
      return [...prev]
    })
  }

  function getEnabledSubItemByType(collect, type) {
    return collect
      .filter((sub) => sub.enabled && sub.type === type)
      .map((sub) => ({ name: `${sub.name}::${sub.value}` }))
  }

  function getEnabledList() {
    return permissions.reduce(
      (json, permission) => {
        let pagePermission = []
        let featurePermission = []
        permission.items.forEach((item) => {
          if (item.top.enabled) {
            pagePermission.push({ name: `${item.top.name}::${item.top.path}` })
          }

          const enabledSubs = item.sub.filter((sub) => sub.enabled)

          if (enabledSubs.length) {
            pagePermission = pagePermission.concat(getEnabledSubItemByType(enabledSubs, 'page'))
            featurePermission = featurePermission.concat(getEnabledSubItemByType(enabledSubs, 'item'))
          }
        })

        if (pagePermission.length) json.page = json.page.concat(pagePermission)
        if (featurePermission.length) json.feature = json.feature.concat(featurePermission)

        return json
      },
      { page: [], feature: [] }
    )
  }

  return (
    <>
      {permissions.map((permission, mainIndex) => (
        <div className='border border-secondary rounded p-3 mb-3' key={mainIndex}>
          {permission.name}
          <hr />
          {permission.items.map((item, topIndex) => (
            <div className='row my-1' key={topIndex}>
              <div className='col-6'>
                <div className='form-check form-switch'>
                  <input
                    type='checkbox'
                    className='form-check-input'
                    id={`top-${mainIndex}-${topIndex}`}
                    onChange={() => topEnabledCallback(mainIndex, topIndex)}
                    checked={item.top.enabled}
                  />
                  <label className='form-check-label' htmlFor={`top-${mainIndex}-${topIndex}`}>
                    {item.top.name}
                  </label>
                </div>
              </div>
              <div className=' col-6'>
                {!!item.sub.length &&
                  item.sub.map((sub, subIndex) => (
                    <div key={subIndex}>
                      <div className='col-12'>
                        <div className='form-check form-switch'>
                          <input
                            type='checkbox'
                            className='form-check-input'
                            id={`sub-${mainIndex}-${topIndex}-${subIndex}`}
                            onChange={() => subEnabledCallback(mainIndex, topIndex, subIndex)}
                            disabled={!item.top.enabled && sub.link}
                            checked={sub.enabled}
                          />
                          <label className='form-check-label' htmlFor={`sub-${mainIndex}-${topIndex}-${subIndex}`}>
                            {sub.name}
                          </label>
                        </div>
                      </div>
                    </div>
                  ))}
              </div>
            </div>
          ))}
        </div>
      ))}
    </>
  )
})
