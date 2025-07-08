import { lazy } from 'react'

export const PERMISSION_ROUTE = {
  name: '權限管理',
  path: '/permissions',
  src: 'permission',
  exact: true,
  comp: lazy(() => import('./index.js'))
}

export const PERMISSION_ACCESS = {
  top: { name: PERMISSION_ROUTE.name, path: PERMISSION_ROUTE.path },
  sub: []
}
