import { LOGIN_ROUTE, INIT_ROUTE } from 'page/login/config'
import { NOT_FOUND_ROUTE } from 'page/error/config'
import { HOME_ROUTE } from 'page/home/config'
import { MEMBER_ROUTE, MEMBER_ADD_ROUTE, MEMBER_UPDATE_ROUTE } from 'page/member/config'
import { PERMISSION_ROUTE } from 'page/permission/config'

/**
 * PACKAGE CONFIG AND PERMISSION
 * 有其一權限則引入整個 array route
 * 要是權限分開設定時, 可個別引入 route 而非 array route
 */

const MEMBER_PACKAGE = [MEMBER_ROUTE, MEMBER_ADD_ROUTE, MEMBER_UPDATE_ROUTE]

export const STATIC_VIEW = [LOGIN_ROUTE, NOT_FOUND_ROUTE, INIT_ROUTE]

export const LAYOUT_GROUP = [HOME_ROUTE]

export const LAYOUT_WITH_PERMISSION_GROUP = [MEMBER_PACKAGE, PERMISSION_ROUTE]

export const LAYOUT_VIEW = [...LAYOUT_GROUP, ...LAYOUT_WITH_PERMISSION_GROUP]
