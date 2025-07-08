import { useSelector, useDispatch } from 'react-redux'

const SET_PERMISSIONS = 'setPermissions'

const reducer = (state = { page: [], feature: [] }, action) => {
  switch (action.type) {
    case SET_PERMISSIONS:
      return { ...action.permissions }
    default:
      return state
  }
}

export const permissionsReducer = { permissions: reducer }

export const usePermissions = () => {
  const permissions = useSelector((state) => state.permissions)
  const dispatch = useDispatch()

  function setPermissions(permissions) {
    dispatch({ type: SET_PERMISSIONS, permissions })
  }

  function hasPagePermission(routeInfo = { name: '', path: '' }) {
    return permissions.page.some((permission) => permission.name === `${routeInfo.name}::${routeInfo.path}`)
  }

  function hasItemPermission(name, alias) {
    return permissions.feature.some((permission) => permission.name === `${name}::${alias}`)
  }

  return [permissions, setPermissions, hasPagePermission, hasItemPermission]
}
