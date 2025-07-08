import { useEffect, useState, Suspense } from 'react'
import { Navigate, Routes } from 'react-router'
import { Route } from 'react-router-dom'
import { NOT_FOUND_ROUTE } from 'page/error/config'
import { LOGIN_ROUTE } from 'page/login/config'
import { HOME_ROUTE } from 'page/home/config'
import { STATIC_VIEW, LAYOUT_GROUP, LAYOUT_WITH_PERMISSION_GROUP } from 'config/router'
import { useMemberInfo } from 'reducer/member-info'
import { usePermissions } from 'reducer/permissions'
import { isNotEmptyObj } from 'utils/forms'
import { compose } from 'utils/lambdas'
import { useHeartBeat } from 'component/heart-beat'

export default () => {
  const [ready, setReady] = useState(false)
  const [routeInfo, setRouteInfo] = useState([])
  const memberInfo = useMemberInfo()[0]
  const [permissions, , hasPagePermission] = usePermissions()

  // TODO:設定網站是否需要設定閒置自動登出
  useHeartBeat(memberInfo)

  useEffect(() => {
    const staticView = buildRouteConstruct(STATIC_VIEW)

    const layoutGroup = isLogin() ? buildRouteConstruct(LAYOUT_GROUP) : []

    const permissionView = isLogin()
      ? compose(buildRouteConstruct, filterWithPermission)(LAYOUT_WITH_PERMISSION_GROUP)
      : []

    setRouteInfo(staticView.concat(layoutGroup).concat(permissionView))

    setReady(true)
  }, [memberInfo, permissions])

  function isLogin() {
    return isNotEmptyObj(memberInfo)
  }

  function buildRouteConstruct(routeArray) {
    return [...routeArray].reduce((array, route) => {
      if (Array.isArray(route)) {
        const newRoutes = [...route].map((item) => ({ ...item, component: item.comp }))
        array = array.concat(newRoutes)
      } else {
        array.push({ ...route, component: route.comp })
      }
      return array
    }, [])
  }

  function filterWithPermission(routeArray) {
    return permissions.page.length > 0
      ? [...routeArray].reduce((array, route) => {
          if (Array.isArray(route)) {
            if (route.some((item) => hasPagePermission(item))) {
              array = array.concat(route)
            }
          } else {
            if (hasPagePermission(route)) {
              array.push(route)
            }
          }
          return array
        }, [])
      : []
  }

  return (
    ready && (
      <Suspense fallback={<div>Loading</div>}>
        <Routes>
          {routeInfo.map((page, index) => (
            <Route key={index} path={page.path} element={<page.component />} />
          ))}

          <Route path='/' element={<Navigate replace to={isLogin() ? HOME_ROUTE.path : LOGIN_ROUTE.path} />} />

          <Route path='*' element={<Navigate replace to={NOT_FOUND_ROUTE.path} />} />
        </Routes>
      </Suspense>
    )
  )
}
