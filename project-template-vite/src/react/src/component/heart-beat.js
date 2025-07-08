import { useEffect } from 'react'
import { privClient, pubClient } from 'utils/rest-client'
import { useNavigate } from 'react-router-dom'
import { LOGIN_ROUTE } from 'page/login/config'
import { isNotEmptyObj } from 'utils/forms'
import { useMemberInfo } from 'reducer/member-info'
import { usePermissions } from 'reducer/permissions'

// TODO:檢查並加長cookie壽命時間 15分鐘 default 1000 * 60 * 15 - 1000
const HEART_BEAT_INTERVAL = 1000 * 60 * 15 - 1000

export const useHeartBeat = (memberInfo = null) => {
  const navigate = useNavigate()
  const setMemberInfo = useMemberInfo()[1]
  const setPermissions = usePermissions()[1]

  return useEffect(() => {
    if (memberInfo && isLogin()) {
      let actionCount = true
      const checkMouseKey = window.addEventListener('mousedown', () => {
        actionCount = true
      })
      const checkKeydown = window.addEventListener('keydown', () => {
        actionCount = true
      })

      const handleHeartBeat = setInterval(() => {
        if (actionCount) {
          keepHeartBeat()
        } else {
          tryKnock()
        }

        actionCount = false
      }, HEART_BEAT_INTERVAL)

      return () => {
        window.removeEventListener('mousedown', checkMouseKey)
        window.removeEventListener('keydown', checkKeydown)
        clearInterval(handleHeartBeat)
      }
    }
  }, [memberInfo])

  async function tryKnock() {
    const loseHeartBeat = () => {
      window.alert('資料連線中斷，請重新登入')

      navigate(LOGIN_ROUTE.path)

      setMemberInfo({})

      setPermissions({ page: [], feature: [] })
    }
    try {
      const { data } = await pubClient.get({}, 'token', 'knock')

      if (!data) {
        loseHeartBeat()
      }

      //eslint-disable-next-line
    } catch (e) {
      window.alert('資料連線中斷，請重新登入')
    }
  }

  async function keepHeartBeat() {
    await privClient.get({}, 'keepHeartBeat')
  }

  function isLogin() {
    return isNotEmptyObj(memberInfo)
  }
}
