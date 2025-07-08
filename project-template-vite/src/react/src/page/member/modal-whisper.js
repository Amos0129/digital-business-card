import React, { useState } from 'react'
import { ModalDialog } from 'component/modal-dialog'
import { jsonCallBack, invalid, required, requireAll, isEmptyObj } from 'utils/forms'
import { WHISPER_FORMAT } from 'page/member/config'
import { pubClient, privClient } from 'utils/rest-client'
import { rsa } from 'utils/ciphers'
import { useSuccessToast, useErrorToast } from 'component/toast'

const STRUCTURE = { oldWhisper: '', newWhisper: '', reWhisper: '' }

export default ({ memberId, account, state = [] }) => {
  const [display, setDisplay] = state
  const [content, setContent] = useState({ ...STRUCTURE })
  const [alert, setAlert] = useState({ ...STRUCTURE })
  const successToast = useSuccessToast()
  const errorToast = useErrorToast()

  function handleOpen() {
    setContent({ ...STRUCTURE })
    setAlert({ ...STRUCTURE })
  }

  function validWhisper(val) {
    return required(val) || (WHISPER_FORMAT.regex.test(val) ? '' : WHISPER_FORMAT.msg)
  }

  function handleOldWhisper(event) {
    const val = event.target.value

    setAlert((prev) => ({ ...prev, oldWhisper: validWhisper(val) }))
  }

  function handleNewWhisper(event) {
    const dom = event.target
    const anotherDomName = dom.name === 'newWhisper' ? 'reWhisper' : 'newWhisper'

    setAlert((prev) => {
      const compareWhisper =
        content[dom.name] && content[anotherDomName] && content[dom.name] !== content[anotherDomName]
          ? '密碼不一致'
          : ''
      const msg = validWhisper(dom.value) || compareWhisper
      const anotherAlert =
        !prev[anotherDomName] || prev[anotherDomName] === '密碼不一致' ? compareWhisper : prev[anotherDomName]
      return { ...prev, [dom.name]: msg, [anotherDomName]: anotherAlert }
    })
  }

  function handleSubmit() {
    const alertClone = requireAll(content, alert)

    setAlert(alertClone)

    if (isEmptyObj(alertClone)) {
      submit()
    }
  }

  async function submit() {
    try {
      const { data: pubKey } = await pubClient.get({ account }, 'steel')
      const encodeOldWhisper = await rsa.encrypt(pubKey, content.oldWhisper)
      const encodeNewWhisper = await rsa.encrypt(pubKey, content.newWhisper)

      const dataBody = {
        account,
        armour1: encodeOldWhisper,
        armour2: encodeNewWhisper
      }

      await privClient.put(dataBody, 'member', memberId, 'whisper')

      successToast('變更密碼成功')

      setDisplay(false)
    } catch (e) {
      if (e.response && e.response.status === 400) {
        errorToast('舊密碼錯誤')
      }
    }
  }

  return (
    <ModalDialog
      visible={display}
      centered
      keyboard='true'
      backdrop
      onOpen={handleOpen}
      onClose={() => setDisplay(false)}
    >
      <>
        <div className='modal-header'>變更密碼</div>

        <div className='modal-body'>
          <div className='mb-3'>
            <label className='form-label' htmlFor='oldWhisper'>
              舊密碼
            </label>
            <input
              className={`form-control ${invalid(alert.oldWhisper)}`}
              id='oldWhisper'
              type='password'
              name='oldWhisper'
              maxLength='50'
              value={content.oldWhisper}
              onChange={jsonCallBack(setContent)}
              onBlur={handleOldWhisper}
            />
            <div className='invalid-feedback'>{alert.oldWhisper}</div>
          </div>

          <div className='mb-3'>
            <label className='form-label' htmlFor='newWhisper'>
              新密碼
            </label>
            <input
              className={`form-control ${invalid(alert.newWhisper)}`}
              id='newWhisper'
              type='password'
              name='newWhisper'
              maxLength='50'
              value={content.newWhisper}
              onChange={jsonCallBack(setContent)}
              onBlur={handleNewWhisper}
            />
            <div className='invalid-feedback'>{alert.newWhisper}</div>
          </div>

          <div className='mb-3'>
            <label className='form-label' htmlFor='reWhisper'>
              確認新密碼
            </label>
            <input
              className={`form-control ${invalid(alert.reWhisper)}`}
              id='reWhisper'
              type='password'
              name='reWhisper'
              maxLength='50'
              value={content.reWhisper}
              onChange={jsonCallBack(setContent)}
              onBlur={handleNewWhisper}
            />
            <div className='invalid-feedback'>{alert.reWhisper}</div>
          </div>
        </div>

        <div className='modal-footer'>
          <button className='btn btn-outline-secondary' onClick={() => setDisplay((prev) => !prev)}>
            關閉
          </button>
          <button className='btn btn-outline-primary' onClick={handleSubmit}>
            確認
          </button>
        </div>
      </>
    </ModalDialog>
  )
}
