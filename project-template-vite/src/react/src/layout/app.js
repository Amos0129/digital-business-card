import { useEffect, useState } from 'react'
import { useLocation, matchPath, useNavigate } from 'react-router'
import { TOP_MENU_PACK, MENU_PACK } from 'config/menu'
import { LAYOUT_VIEW, STATIC_VIEW } from 'config/router'
import { usePermissions } from 'reducer/permissions'
import { useMemberInfo } from 'reducer/member-info'
import { useMenuToggle } from 'reducer/menu-toggle'
import { LOGIN_ROUTE } from 'page/login/config'
import Router from 'layout/router'
import Sidebar from 'layout/sidebar'
import TopMenu from 'layout/top-menu'
import { pubClient } from 'utils/rest-client'

const IfDiv = (props) => (props.bool ? <div className={props.className}>{props.children}</div> : <>{props.children}</>)

export default () => {
  const [ready, setReady] = useState(false)
  const setMemberInfo = useMemberInfo()[1]
  const setPermissions = usePermissions()[1]
  const location = useLocation()
  const [inLayout, setInLayout] = useState(false)
  const menutoggle = useMenuToggle()[0]
  const navigate = useNavigate()

  useEffect(() => {
    async function knock() {
      try {
        const { data } = await pubClient.get({}, 'token', 'knock')
        if (data.userInfo) {
          setMemberInfo(data.userInfo)
        }

        if (data.permission) {
          setPermissions(data.permission)
        }
        //eslint-disable-next-line
      } catch (e) {
        window.alert('資料連線中斷，請重新登入')

        setMemberInfo({})

        setPermissions({ page: [], feature: [] })

        const isStaticView = STATIC_VIEW.map((view) => view.path).includes(location.pathname)

        if (isStaticView) {
          navigate(LOGIN_ROUTE.path)
        }
      }
      setReady(true)
    }

    knock()
  }, [])

  useEffect(() => {
    const __MATCH__ = (routeInfo) => matchPath({ path: routeInfo.path, exact: routeInfo.exact }, location.pathname)

    const isInLayout = [...LAYOUT_VIEW].some((view) =>
      Array.isArray(view) ? view.some((sub) => __MATCH__(sub)) : __MATCH__(view)
    )

    setInLayout(isInLayout)
  }, [location.pathname])

  return (
    ready && (
      <IfDiv bool={inLayout} className='app-container'>
        {inLayout && MENU_PACK.length > 0 && <Sidebar />}

        <IfDiv
          bool={inLayout}
          className={`app-content ${MENU_PACK.length > 0 ? 'app-content-side' : ''} ${menutoggle ? '' : 'fullscreen'}`}
        >
          {inLayout && TOP_MENU_PACK.length > 0 && (
            <div
              className={`d-flex justify-content-between app-header shadow rounded py-2 
                ${menutoggle ? 'mx-2' : 'ms-5 me-2'}`}
            >
              <TopMenu />
            </div>
          )}
          <IfDiv bool={inLayout} className='app-content-inline'>
            <Router />
          </IfDiv>
        </IfDiv>
      </IfDiv>
    )
  )
}
