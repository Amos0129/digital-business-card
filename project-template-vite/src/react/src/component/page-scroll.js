import { useEffect } from 'react'

export default (dataArray, tableEle) =>
  useEffect(() => {
    if (dataArray.length) {
      document.getElementById('root').scroll({
        behavior: 'smooth',
        top: tableEle.getBoundingClientRect().top + document.getElementById('root').scrollTop,
        left: 0
      })
    }
  }, [dataArray])
