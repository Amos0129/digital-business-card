import { useState, useRef } from 'react'

export default (props) => {
  const defaultValues = props || null
  const [entity, setEntity] = useState(defaultValues)
  const entityRef = useRef(defaultValues)

  function setFunc(val) {
    if (typeof val === 'function') {
      let temp

      setEntity((prev) => {
        temp = val(prev)

        entityRef.current = temp

        return temp
      })
    } else {
      setEntity(val)
      entityRef.current = val
    }
  }
  return [entityRef, entity, setFunc]
}
