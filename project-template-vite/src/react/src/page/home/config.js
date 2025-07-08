import { lazy } from 'react'

export const HOME_ROUTE = {
  name: '首頁',
  path: '/home',
  src: 'home',
  exact: true,
  comp: lazy(() => import('./index.js'))
}
