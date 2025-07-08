import { useState, useEffect, useReducer, forwardRef, useImperativeHandle } from 'react'

const PageHead = ({ disabled, onClick = () => {}, children }) => (
  <li className={`page-item ${disabled ? 'disabled' : 'c-pointer'}`}>
    <div className='page-link' onClick={onClick}>
      <span aria-hidden='true'>{children}</span>
    </div>
  </li>
)

function computedGroup(origin, action) {
  const { totalPage, start } = action

  if (totalPage <= 5) {
    return [...Array(totalPage)].map((empty, index) => index)
  } else if (start <= 2) {
    return [...Array(5)].map((empty, index) => index)
  } else if (start > 2 && start + 2 < totalPage) {
    return [...Array(5)].map((empty, index) => start + index - 2)
  } else if (start + 2 >= totalPage) {
    return [...Array(5)].map((empty, index) => start + index - (start + 1 === totalPage ? 4 : 3))
  } else {
    return []
  }
}

export default forwardRef(
  //eslint-disable-next-line
  ({ className, per, onPage = (start, perItem) => {} }, ref) => {
    const [current, setCurrent] = useState(0)
    const [totalPage, setTotalPage] = useState(0)
    const [totalItem, setTotalItem] = useState(0)
    const [group, disGroup] = useReducer(computedGroup, [])
    const [perPage, setPerPage] = useState(per || 20)

    useEffect(() => {
      const computedPer = perPage || per

      const countTotalPage = Math.ceil(totalItem / computedPer)

      disGroup({ totalPage: countTotalPage, start: current })

      setTotalPage(countTotalPage)

      setPerPage(computedPer)
    }, [totalItem, per])

    useImperativeHandle(ref, () => ({
      setTotalItem: setTotalItem,
      setCurrent: (number) => setCurrent(parseInt(number)),
      onStart: () => changePage(0),
      pageArgs: { current: current, perPage: perPage }
    }))

    function changePage(pageNumber) {
      setCurrent(pageNumber)

      disGroup({ totalPage: totalPage, start: pageNumber })

      onPage({ current: pageNumber, perPage: perPage })
    }

    return (
      <ul className='pagination'>
        <PageHead disabled={current === 0} onClick={() => changePage(0)}>
          &laquo;
        </PageHead>
        <PageHead disabled={current === 0} onClick={() => changePage(current - 1 || 0)}>
          &lsaquo;
        </PageHead>

        {group.map((pageNumber) => (
          <li className={`page-item ${pageNumber === current ? 'active c-default' : 'c-pointer'}`} key={pageNumber}>
            <div className='page-link' onClick={() => current !== pageNumber && changePage(pageNumber)}>
              {pageNumber + 1}
            </div>
          </li>
        ))}

        <PageHead disabled={current + 1 === totalPage} onClick={() => changePage(current + 1)}>
          &rsaquo;
        </PageHead>
        <PageHead disabled={current + 1 === totalPage} onClick={() => changePage(totalPage - 1)}>
          &raquo;
        </PageHead>
      </ul>
    )
  }
)
