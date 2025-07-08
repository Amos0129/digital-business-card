import { lazy } from 'react'

export const MEMBER_ROUTE = {
  name: '帳號管理',
  path: '/members',
  src: 'member',
  exact: true,
  comp: lazy(() => import('./index.js'))
}
export const MEMBER_ADD_ROUTE = {
  name: '建立帳號',
  path: '/member',
  src: 'member/add',
  exact: true,
  comp: lazy(() => import('./add.js'))
}
export const MEMBER_UPDATE_ROUTE = {
  name: '修改帳號',
  path: '/member/:memberId',
  src: 'member/update',
  exact: true,
  comp: lazy(() => import('./update.js'))
}
export const WHISPER_FORMAT = {
  regex: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d.*)(?=.*\W.*)[a-zA-Z0-9\W\s]{12,16}$/,
  msg: '長度需介於 12 ~ 16 碼, 且同時含有數字、英文子母大小寫和至少一個以下特殊符號 ~!@#$%^&*-+=<,>.?|;:'
}

export const STATUS_MAP = {
  '-1': '未啟用',
  0: '停用',
  1: '啟用'
}

export const MEMBER_PERMISSION = {
  top: { name: MEMBER_ROUTE.name, path: MEMBER_ROUTE.path },
  sub: []
}

export const validateWhisper = (val) => WHISPER_FORMAT.regex.test(val)
