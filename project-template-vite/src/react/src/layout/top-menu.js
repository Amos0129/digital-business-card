import { useState, useEffect } from 'react'
import { useNavigate, Link, Navigate } from 'react-router-dom'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faCircleUser } from '@fortawesome/free-solid-svg-icons'
import { TOP_MENU_PACK } from 'config/menu'
import { LAYOUT_GROUP } from 'config/router'
import { LOGIN_ROUTE } from 'page/login/config'
import { useMemberInfo } from 'reducer/member-info'
import { usePermissions } from 'reducer/permissions'
import { preventHref, isNotEmptyObj } from 'utils/forms'
import { privClient } from 'utils/rest-client'

export default () => {
  const navigate = useNavigate()
  const [memberInfo, setMemberInfo] = useMemberInfo()
  const [permissions, setPermissions, hasPagePermission] = usePermissions()
  const [permissionMenu, setPermissionMenu] = useState([])
  const [isLogout, setLogout] = useState(false)

  useEffect(() => {
    const menuList = [...TOP_MENU_PACK].reduce((array, menu) => {
      if (isNotEmptyObj(menu)) {
        if (menu?.items?.length > 1) {
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
          if (hasPagePermission(menu?.items[0])) {
            array.push(menu)
          }

          if (LAYOUT_GROUP.some((layout) => layout.name === menu?.items[0].name)) {
            array.push(menu)
          }
        }
      }

      return array
    }, [])

    setPermissionMenu(menuList)
  }, [permissions])

  function handleNavClick(path) {
    navigate(path)
  }

  async function logout() {
    await privClient.get({}, 'logout')

    setMemberInfo({})

    setPermissions({ page: [], feature: [] })

    setLogout(true)
  }

  return (
    <>
      {isLogout && <Navigate to={LOGIN_ROUTE.path} replace />}
      <div>
        <nav className='navbar navbar-expand-lg'>
          <div className='container-fluid'>
            <button
              className='navbar-toggler'
              type='button'
              data-bs-toggle='collapse'
              data-bs-target='#navbarSupportedContent'
              aria-controls='navbarSupportedContent'
              aria-expanded='false'
              aria-label='Toggle navigation'
            >
              <span className='navbar-toggler-icon' />
            </button>
            <div className='collapse navbar-collapse' id='navbarSupportedContent'>
              <ul className='navbar-nav d-flex'>
                {permissionMenu.map((menu, index) =>
                  menu.items.length > 1 ? (
                    <li key={`top-${index}`} className='nav-item dropdown'>
                      <Link
                        className='nav-link dropdown-toggle'
                        role='button'
                        data-bs-toggle='dropdown'
                        aria-expanded='false'
                      >
                        {menu.name}
                      </Link>
                      <ul className='dropdown-menu'>
                        {menu.items.map((item, sub) => (
                          <li key={`top-${index}-${sub}`}>
                            <Link className='dropdown-item' to={item.path}>
                              {item.name}
                            </Link>
                          </li>
                        ))}
                      </ul>
                    </li>
                  ) : (
                    <li className='nav-item' key={`top-${index}`}>
                      <Link
                        className='nav-link'
                        to={menu.items[0].path}
                        onClick={preventHref(() => handleNavClick(menu.items[0].path))}
                      >
                        {menu.items[0].name}
                      </Link>
                    </li>
                  )
                )}
              </ul>
            </div>
          </div>
        </nav>
      </div>
      <div className='pe-2 fs-5 d-flex dropdown'>
        <button
          className='btn btn-outline-light dropdown-toggle border-0 text-primary'
          type='button'
          data-bs-toggle='dropdown'
          aria-expanded='false'
        >
          <FontAwesomeIcon className='fs-5 me-1' icon={faCircleUser} /> {memberInfo.name}
        </button>
        <ul className='dropdown-menu app-dropdown-menu dropdown-menu-end'>
          <li>
            <button className='dropdown-item' onClick={logout}>
              登出
            </button>
          </li>
        </ul>
      </div>
    </>
  )
}
