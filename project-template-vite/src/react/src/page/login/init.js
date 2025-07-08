import React, { useState, useEffect } from 'react'
import { jsonCallBack, invalid, required, isNotEmptyObj } from 'utils/forms'
import { pubClient } from 'utils/rest-client'
import { useSuccessToast, useErrorToast } from 'component/toast'
import ButtonBlock from 'component/button-block'
import { rsa } from 'utils/ciphers'
import { validateWhisper, WHISPER_FORMAT } from 'page/member/config'
import { useNavigate } from 'react-router'

export default ({ countMemberCallback = () => {} }) => {
  const successToast = useSuccessToast()
  const errorToast = useErrorToast()
  const navigate = useNavigate()

  const DEFAULT_MEMBER = {
    account: '',
    name: '',
    whisper: '',
    reWhisper: ''
  }

  const [member, setMember] = useState({ ...DEFAULT_MEMBER })
  const [alert, setAlert] = useState({ ...DEFAULT_MEMBER })
  const [btnDisabled, setBtnDisabled] = useState(false)
  const [memberExist, setMemberExist] = useState(true)

  useEffect(() => {
    checkMemberExist()
  }, [])

  async function checkMemberExist() {
    const isExist = (await (await pubClient.get({}, 'account', 'count')).data) > 0

    if (isExist) {
      navigate('/')
    }

    setMemberExist(isExist)
  }

  function checkRequired(domName) {
    const alertMsg = required(member[domName], '必填')
    setAlert({ ...alert, [domName]: alertMsg })
  }

  function checkWhisperAndReWhisper(currentDomName, alertObj = null) {
    const anotherDomName = currentDomName === 'whisper' ? 'reWhisper' : 'whisper'
    const alertClone = alertObj || { ...alert }
    if (!member[currentDomName]) {
      alertClone[currentDomName] = '必填'
    } else if (!validateWhisper(member[currentDomName])) {
      alertClone[currentDomName] = WHISPER_FORMAT.msg
    } else if (member[anotherDomName] && member[currentDomName] !== member[anotherDomName]) {
      alertClone[currentDomName] = '兩次密碼輸入不相同'
      alertClone[anotherDomName] = alertClone[anotherDomName] || '兩次密碼輸入不相同'
    } else {
      alertClone[currentDomName] = ''
      alertClone[anotherDomName] = ''
    }
    return alertClone
  }

  async function buildMember() {
    let alertClone = { ...alert }
    alertClone = checkWhisperAndReWhisper('whisper', alertClone)
    alertClone = checkWhisperAndReWhisper('reWhisper', alertClone)
    alertClone.account = required(member.account, '必填')
    alertClone.name = required(member.name, '必填')

    if (!isNotEmptyObj(alertClone)) {
      const { data: pubKey } = await pubClient.get({ account: member.account }, 'steel')
      const encodedWhisper = await rsa.encrypt(pubKey, member.whisper)
      const memberClone = { ...member, armour: encodedWhisper }
      delete memberClone.reWhisper
      try {
        await pubClient.post(memberClone, 'account', 'init')
        successToast('建立帳號成功')
        await countMemberCallback()
        navigate('/')
      } catch {
        errorToast('建立帳號失敗')
        setBtnDisabled(true)
      }
    } else {
      setAlert(alertClone)
    }
  }

  return (
    !memberExist && (
      <div className='welcome'>
        <h1 className='text-center welcome-title'>建立您的第一個帳號</h1>
        <div className='row'>
          <div className='form-group col-12'>
            <label htmlFor='account' className='col-form-label'>
              帳號
            </label>
            <input
              type='text'
              className={`form-control ${invalid(alert.account)}`}
              id='account'
              name='account'
              onChange={jsonCallBack(setMember)}
              onBlur={(e) => checkRequired(e.target.name)}
            />
            <div className='invalid-feedback'>{alert.account}</div>
          </div>
          <div className='form-group col-12'>
            <label htmlFor='whisper' className='col-form-label'>
              密碼
            </label>
            <input
              type='password'
              className={`form-control ${invalid(alert.whisper)}`}
              id='whisper'
              name='whisper'
              onChange={jsonCallBack(setMember)}
              onBlur={(e) => {
                const alertClone = checkWhisperAndReWhisper(e.target.name)
                setAlert(alertClone)
              }}
            />
            <div className='invalid-feedback'>{alert.whisper}</div>
          </div>
          <div className='form-group col-12'>
            <label htmlFor='reWhisper' className='col-form-label'>
              確認密碼
            </label>
            <input
              type='password'
              className={`form-control ${invalid(alert.reWhisper)}`}
              id='reWhisper'
              name='reWhisper'
              onChange={jsonCallBack(setMember)}
              onBlur={(e) => {
                const alertClone = checkWhisperAndReWhisper(e.target.name)
                setAlert(alertClone)
              }}
            />
            <div className='invalid-feedback'>{alert.reWhisper}</div>
          </div>
          <div className='form-group col-12'>
            <label htmlFor='name' className='col-form-label'>
              姓名
            </label>
            <input
              type='text'
              className={`form-control ${invalid(alert.name)}`}
              id='name'
              name='name'
              onChange={jsonCallBack(setMember)}
              onBlur={(e) => checkRequired(e.target.name)}
            />
            <div className='invalid-feedback'>{alert.name}</div>
          </div>
        </div>
        <ButtonBlock className='btn btn-outline-primary w-100 my-3' onClick={buildMember} disabled={btnDisabled}>
          建立帳號
        </ButtonBlock>
      </div>
    )
  )
}
