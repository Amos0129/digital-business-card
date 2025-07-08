import { lazy } from 'react'

export const LOGIN_ROUTE = {
  name: '登入',
  path: '/login',
  src: 'login',
  exact: true,
  comp: lazy(() => import('./index.js'))
}
export const INIT_ROUTE = {
  name: 'init',
  path: '/init',
  src: 'login/init',
  exact: true,
  comp: lazy(() => import('./init.js'))
}
