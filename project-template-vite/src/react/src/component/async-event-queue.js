import { useRef, useEffect } from 'react'

export default () => {
  const promiseChain = useRef({})

  function handleFocus(func) {
    return (event) => {
      promiseChain.current[event.target.name] = {
        func: func,
        status: 'pending'
      }
    }
  }

  async function handleBlur(event) {
    const dom = event.target
    if (promiseChain.current[dom.name]) {
      promiseChain.current[dom.name].status = 'running'
      promiseChain.current[dom.name].func = promiseChain.current[dom.name].func(dom)
      await promiseChain.current[dom.name].func
      delete promiseChain.current[dom.name]
    }
  }

  async function awaitAllEvent() {
    if (Object.keys(promiseChain.current).length) {
      const promiseQueue = Object.keys(promiseChain.current).reduce((chain, jian) => {
        switch (promiseChain.current[jian].status) {
          case 'pending':
            chain.push(promiseChain.current[jian].func(document.getElementById(jian)))
            break
          case 'running':
            chain.push(promiseChain.current[jian].func)
            break
          default:
            break
        }
        return chain
      }, [])

      await Promise.all(promiseQueue)

      promiseChain.current = {}
    }
  }

  useEffect(
    () => () => {
      promiseChain.current = {}
    },
    []
  )

  return [handleFocus, handleBlur, awaitAllEvent]
}
