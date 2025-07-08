import { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faAngleDoubleLeft, faAlignJustify } from '@fortawesome/free-solid-svg-icons'
import Menu from 'layout/menu'
import { HOME_ROUTE } from 'page/home/config'
import { useMenuToggle } from 'reducer/menu-toggle'
import { pubClient } from 'utils/rest-client'

export default () => {
  const [versionInfo, setVersionInfo] = useState('')
  const [menuToggle, setMenuToggle] = useMenuToggle()

  useEffect(() => {
    ;(async () => {
      const { data } = await pubClient.get({}, 'version')
      setVersionInfo(data)
    })()
  }, [])

  return (
    <div className={`side-nav ${menuToggle ? 'active' : 'inactive'}`}>
      <div className='d-flex' onClick={() => setMenuToggle(!menuToggle)}>
        <FontAwesomeIcon className='sidebar-icon' icon={faAlignJustify} />
      </div>
      <div className={`sidebar ${menuToggle ? 'on' : 'off'}`}>
        <div className='sidebar-scroll' id='sidebar-style'>
          <div className='d-flex justify-content-end sidebar-head' onClick={() => setMenuToggle(!menuToggle)}>
            <FontAwesomeIcon className='sidebar-icon' icon={faAngleDoubleLeft} />
          </div>
          <div className='sidebar-content'>
            <Link to={HOME_ROUTE.path}>
              <h1>Header here</h1>
            </Link>
            <div className='sidebar-version'>ver {versionInfo}</div>
          </div>
          <Menu />
        </div>
      </div>
    </div>
  )
}
