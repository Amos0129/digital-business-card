import { useRef, useState } from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faAngleUp, faAngleDown } from '@fortawesome/free-solid-svg-icons'
import { Link } from 'react-router-dom'
import { Collapse } from 'bootstrap'

export default ({ menu }) => {
  const [isOpen, setIsOpen] = useState(false)
  const collapseRef = useRef(null)

  function toggle() {
    new Collapse(collapseRef.current).toggle()

    setIsOpen((prev) => !prev)
  }

  return (
    <>
      <div className='d-flex align-items-center justify-content-between menu-item ' onClick={toggle}>
        <div className='d-flex'>{menu.name}</div>
        <FontAwesomeIcon className='menu-icon' icon={isOpen ? faAngleUp : faAngleDown} />
      </div>
      <div className='collapse' ref={collapseRef}>
        {menu.items.map((item, sub) => (
          <div key={sub} className='menu-sub-item '>
            <Link className='menu-sub-link' to={item.path}>
              {item.name}
            </Link>
          </div>
        ))}
      </div>
    </>
  )
}
