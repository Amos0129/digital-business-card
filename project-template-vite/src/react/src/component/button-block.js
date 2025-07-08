import { useState, useEffect, forwardRef, useImperativeHandle, useRef, useReducer } from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faCircleNotch } from '@fortawesome/free-solid-svg-icons'

/**
 * 使用時像一般 button 使用即可
 * 請切記傳入的 onClick 必須為 async
 * 如需要觸發包裝後的 submit 行為，請透過 useRef 獲得 instance 呼叫 buttonBlockCallback
 */

function filterProps(origin = {}, action) {
  if (action.props) {
    return Object.keys(action.props)
      .filter((jian) => !jian.includes(['onClick', 'disabled', 'ref', 'children']))
      .reduce((json, jian) => {
        json[jian] = action.props[jian]
        return json
      }, {})
  } else {
    return origin
  }
}

export default forwardRef((props, ref) => {
  const avoidLeak = useRef(false)
  const [block, setBlock] = useState(false)
  const [attributes, dispatchAttr] = useReducer(filterProps, {})

  useImperativeHandle(ref, () => ({
    buttonBlockCallback: asyncEvent,
    disabled: setBlock
  }))

  useEffect(
    () => () => {
      avoidLeak.current = true
    },
    []
  )

  useEffect(() => {
    dispatchAttr({ props })
  }, [props.className])

  async function asyncEvent() {
    setBlock(true)

    await props.onClick()

    if (!avoidLeak.current) {
      setBlock(false)
    }
  }

  return (
    <button className={attributes.className} onClick={asyncEvent} disabled={block} ref={ref}>
      {block ? (
        <>
          <FontAwesomeIcon icon={faCircleNotch} spin /> 請稍後
        </>
      ) : (
        <>{props.children}</>
      )}
    </button>
  )
})
