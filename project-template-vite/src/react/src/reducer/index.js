import { combineReducers } from 'redux'
import { memberInfoReducer } from 'reducer/member-info'
import { permissionsReducer } from 'reducer/permissions'
import { menuToggleReducer } from 'reducer/menu-toggle'

export default combineReducers({
  ...memberInfoReducer,
  ...permissionsReducer,
  ...menuToggleReducer
})
