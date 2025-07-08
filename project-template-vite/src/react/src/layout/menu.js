import { useState, useEffect } from 'react'
import { useNavigate, Link, Navigate } from 'react-router-dom'
import { MENU_PACK } from 'config/menu'
import MenuItem from 'layout/menu-item'
import { LOGIN_ROUTE } from 'page/login/config'
import { useMemberInfo } from 'reducer/member-info'
import { usePermissions } from 'reducer/permissions'
import { preventHref } from 'utils/forms'
import { privClient } from 'utils/rest-client'

export default () => {
  const navigate = useNavigate()
  const setMemberInfo = useMemberInfo()[1]
  const [permissions, setPermissions, hasPagePermission] = usePermissions()
  const [permissionMenu, setPermissionMenu] = useState([])
  const [isLogout, setLogout] = useState(false)

  useEffect(() => {
    const menuList = [...MENU_PACK].reduce((array, menu) => {
      if (menu.items.length > 1) {
        const subPermissionMenu = [...menu.items].reduce((subArray, subMenu) => {
          if (hasPagePermission(subMenu)) {
            subArray.push(subMenu)
          }
          return subArray
        }, [])

        if (subPermissionMenu.length) {
          array.push({ ...menu, items: subPermissionMenu })
        }
      } else {
        if (hasPagePermission(menu.items[0])) {
          array.push(menu)
        }
      }

      return array
    }, [])

    setPermissionMenu(menuList)
  }, [permissions])

  async function logout() {
    await privClient.get({}, 'logout')

    setMemberInfo({})

    setPermissions({ page: [], feature: [] })

    setLogout(true)
  }

  function handleNavClick(path) {
    navigate(path)
  }

  return (
    <div className='menu-container'>
      {isLogout && <Navigate to={LOGIN_ROUTE.path} replace />}
      {permissionMenu.map((menu, index) =>
        menu.items.length > 1 ? (
          <MenuItem key={index} menu={menu} />
        ) : (
          <div className='menu-li nav-item' key={index}>
            <Link
              className='menu-li-item'
              to={menu.items[0].path}
              onClick={preventHref(() => handleNavClick(menu.items[0].path))}
            >
              {menu.items[0].name}
            </Link>
          </div>
        )
      )}
      <div className='w-100 menu-logout'>
        <button onClick={logout} className='btn btn-outline-secondary menu-button'>
          登出
        </button>
      </div>
    </div>
  )
}
