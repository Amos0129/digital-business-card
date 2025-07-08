import { useState, useRef } from 'react'
import { privClient } from 'utils/rest-client'
import { jsonCallBack } from 'utils/forms'
import ButtonBlock from 'component/button-block'
import { STATUS_MAP, MEMBER_ADD_ROUTE } from 'page/member/config'
import { Link, useLocation, useNavigate } from 'react-router-dom'
import Pagination from 'component/pagination'
import usePageScroll from 'component/page-scroll'
import usePageRouteQuery from 'component/page-route-query'

export default () => {
  const navigate = useNavigate()
  const location = useLocation()
  const pageRef = useRef(null)
  const tableRef = useRef(null)
  const [filter, setFilter] = useState({ account: '', name: '', status: '' })
  const [members, setMembers] = useState([])
  const [ready, setReady] = useState(false)

  function handlePage(pageArgs) {
    const concatArgs = { ...filter, ...pageArgs }

    const queryString = new URLSearchParams()
    Object.keys(concatArgs).forEach((jian) => queryString.append(jian, concatArgs[jian]))
    navigate(`${location.pathname}?${queryString.toString()}`)
  }

  async function handleQuery(queryParams) {
    try {
      const { data } = await privClient.get(queryParams, 'members')
      pageRef.current.setTotalItem(data.count)
      setMembers(data.body)
      //eslint-disable-next-line
    } catch (e) {
      pageRef.current.setTotalItem(0)
      pageRef.current.setCurrent(0)
      setMembers([])
    }
    setReady(true)
  }

  function handleQueryParmas(urlParams) {
    setFilter({ ...urlParams })
  }

  usePageRouteQuery(pageRef, filter, handleQuery, handleQueryParmas)

  usePageScroll(members, tableRef.current)

  return (
    <div className='p-3 border border-secondary rounded'>
      <div className='row mb-3'>
        <label htmlFor='account' className='col-2 col-form-label text-end'>
          帳號
        </label>
        <div className='col-10'>
          <input
            type='text'
            className='form-control'
            id='account'
            name='account'
            placeholder='請輸入帳號'
            value={filter.account}
            onChange={jsonCallBack(setFilter)}
          />
        </div>
      </div>

      <div className='row mb-3'>
        <label htmlFor='name' className='col-2 col-form-label text-end'>
          名稱
        </label>
        <div className='col-10'>
          <input
            type='text'
            className='form-control'
            id='name'
            name='name'
            placeholder='請輸入名稱'
            value={filter.name}
            onChange={jsonCallBack(setFilter)}
          />
        </div>
      </div>

      <div className='row mb-3'>
        <label htmlFor='status' className='col-2 col-form-label text-end'>
          狀態
        </label>
        <div className='col-10'>
          <select
            className='form-select'
            id='status'
            name='status'
            value={filter.status}
            onChange={jsonCallBack(setFilter)}
          >
            <option value=''>請選擇</option>
            {Object.keys(STATUS_MAP).map((jian, index) => (
              <option value={jian} key={index}>
                {STATUS_MAP[jian]}
              </option>
            ))}
          </select>
        </div>
      </div>

      <ButtonBlock className='w-100 btn btn-outline-success' onClick={() => pageRef.current.onStart()}>
        查詢
      </ButtonBlock>

      <table className={`table table-hover border mt-3 ${members.length ? '' : 'd-none'}`} ref={tableRef}>
        <caption>
          <Pagination ref={pageRef} onPage={handlePage} />
        </caption>
        <thead>
          <tr>
            <th>帳號</th>
            <th>名稱</th>
            <th>狀態</th>
          </tr>
        </thead>
        <tbody>
          {members.map((rowData, index) => (
            <tr key={index}>
              <td>
                <Link to={`/member/${rowData.id}`}>{rowData.account}</Link>
              </td>
              <td>{rowData.name}</td>
              <td>{STATUS_MAP[rowData.status]}</td>
            </tr>
          ))}
        </tbody>
      </table>
      {ready && members.length === 0 && (
        <div className='alert alert-warning mt-3' role='alert'>
          查無結果，請重新設定搜尋條件
        </div>
      )}

      <Link className='btn btn-info' to={MEMBER_ADD_ROUTE.path}>
        新增
      </Link>
    </div>
  )
}
