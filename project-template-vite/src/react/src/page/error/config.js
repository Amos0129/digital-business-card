import { lazy } from 'react'

export const NOT_FOUND_ROUTE = {
  name: '找不到網頁',
  path: '/404',
  src: 'error',
  exact: true,
  comp: lazy(() => import('./index.js'))
}
