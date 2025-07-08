import { useEffect } from 'react'
import { useLocation } from 'react-router-dom'

export default (
  pageRef,
  args,
  // eslint-disable-next-line
  onQuery = (params) => {},
  // eslint-disable-next-line
  onQueryParams = (params) => {}
) => {
  const location = useLocation()

  return useEffect(() => {
    const queryString = new URLSearchParams(location.search)

    if (queryString.toString()) {
      const params = {}
      const pageArgs = pageRef.current.pageArgs

      Object.keys(args).forEach((jian) => {
        params[jian] = queryString.get(jian) || ''
      })
      Object.keys(pageArgs).forEach((jian) => {
        params[jian] = queryString.get(jian) || pageArgs[jian]
      })

      if (params.current) {
        pageRef.current.setCurrent(params.current)
      }

      onQuery(params)

      onQueryParams(params)
    } else {
      Object.keys(args).forEach((key) => queryString.append(key, args[key]))

      pageRef.current.onStart(args.current)
    }
  }, [location.search])
}
