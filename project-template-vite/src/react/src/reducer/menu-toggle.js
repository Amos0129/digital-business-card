import { useSelector, useDispatch } from 'react-redux'

const SET_MENU_TOGGLE = 'setMenuToggle'

const reducer = (state = true, action) => {
  switch (action.type) {
    case SET_MENU_TOGGLE:
      return action.menuToggle
    default:
      return state
  }
}

export const menuToggleReducer = { menuToggle: reducer }

export const dispatchMenuToggle = (menuToggle) => ({
  type: SET_MENU_TOGGLE,
  menuToggle
})

export const useMenuToggle = () => {
  const menuToggle = useSelector((state) => state.menuToggle)
  const dispatch = useDispatch()

  function setMenuToggle(menuToggle) {
    dispatch(dispatchMenuToggle(menuToggle))
  }

  return [menuToggle, setMenuToggle]
}
