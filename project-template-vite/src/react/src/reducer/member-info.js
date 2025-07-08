import { useSelector, useDispatch } from 'react-redux'

const SET_MEMBER_INFO = 'setMemberInfo'

const reducer = (state = {}, action) => {
  switch (action.type) {
    case SET_MEMBER_INFO:
      return { ...action.memberInfo }
    default:
      return state
  }
}

export const memberInfoReducer = { memberInfo: reducer }

export const dispatchMembderInfo = (memberInfo) => ({
  type: SET_MEMBER_INFO,
  memberInfo: memberInfo
})

export const useMemberInfo = () => {
  const memberInfo = useSelector((state) => state.memberInfo)
  const dispatch = useDispatch()

  function setMemberInfo(userInfo) {
    dispatch(dispatchMembderInfo(userInfo))
  }

  return [memberInfo, setMemberInfo]
}
