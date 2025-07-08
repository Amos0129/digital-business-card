import { forwardRef, useEffect, useImperativeHandle, useMemo, useRef } from 'react'
import { Modal } from 'bootstrap'

const SIZE_MAP = {
  sm: 'modal-sm',
  lg: 'modal-lg',
  xl: 'modal-xl'
}

const FULLSCREEN_MAP = {
  always: 'modal-fullscreen',
  sm: 'modal-fullscreen-sm-down',
  md: 'modal-fullscreen-md-down',
  lg: 'modal-fullscreen-lg-down',
  xl: 'modal-fullscreen-xl-down',
  xxl: 'modal-fullscreen-xxl-down'
}

export const ModalDialog = forwardRef(
  (
    {
      visible = false,
      children,
      size = '',
      keyboard = false,
      backdrop = false,
      centered = false,
      scrollable = false,
      fullscreen = '',
      onOpen = () => {},
      onClose = () => {}
    },
    ref
  ) => {
    const modalRef = useRef(null)

    const modalInstance = useMemo(() => (modalRef.current ? new Modal(modalRef.current) : null), [modalRef.current])

    useEffect(() => {
      modalRef.current.addEventListener('show.bs.modal', onOpen)
      modalRef.current.addEventListener('hide.bs.modal', onClose)
    }, [onOpen, onClose])

    useEffect(() => {
      if (modalInstance != null) {
        if (visible) {
          modalInstance.show()
        } else {
          modalInstance.hide()
        }
      }
    }, [visible, modalInstance])

    useImperativeHandle(ref, () => ({
      ref: modalRef.current,
      instance: modalInstance
    }))

    const dialogStyle = useMemo(() => {
      const styles = []

      if (SIZE_MAP[size]) styles.push(SIZE_MAP[size])
      if (FULLSCREEN_MAP[fullscreen]) styles.push(FULLSCREEN_MAP[fullscreen])
      if (centered) styles.push('modal-dialog-centered')
      if (scrollable) styles.push('modal-dialog-scrollable')

      return styles.reduce((str, style) => `${str} ${style}`, 'modal-dialog')
    }, [size, fullscreen, centered, scrollable])

    return (
      <div
        className='modal fade'
        tabIndex='-1'
        ref={modalRef}
        data-bs-keyboard={keyboard}
        data-bs-backdrop={backdrop ? 'static' : true}
      >
        <div className={dialogStyle}>
          <div className='modal-content'>{children}</div>
        </div>
      </div>
    )
  }
)
