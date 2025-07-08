export const isNotEmptyObj = (json) => Object.keys(json).some((key) => json[key])

export const isEmptyObj = (json) => !isNotEmptyObj(json)

export const requireAll = (entity, alert, ignore = []) =>
  Object.keys(alert)
    .filter((jian) => ignore.length === 0 || !ignore.includes(jian))
    .reduce((clone, jian) => {
      clone[jian] = alert[jian] || required(entity[jian])
      return clone
    }, {})

export const required = (val) => (val || val === 0 ? '' : '必填')

export const invalid = (val) => (val ? 'is-invalid' : '')

export const EMAIL_FORMAT = {
  regex: /^\w+((-\w+)|(\.\w+))*@[A-Za-z0-9]+((\.|-)[A-Za-z0-9]+)*\.[A-Za-z]+$/,
  msg: '請輸入正確格式的電子信箱'
}

export const jsonCallBack = (setFunc) => (event) => {
  const dom = event.target
  setFunc((prev) => ({ ...prev, [dom.name]: dom.value }))
}

export const textCallBack = (setFunc) => (event) => {
  const dom = event.target
  setFunc(dom.value)
}

export const preventHref =
  (func = () => {}) =>
  (event) => {
    event.preventDefault()
    func()
  }

export const pressEnterCallback = (triggerFunc) => (event) => {
  const charCode = event.which || event.keyCode
  if (charCode === 13) {
    triggerFunc()
  }
}

export const onlyNumber = (event) => {
  const keyCode = event.keyCode ? event.keyCode : event.which
  if ((keyCode < 48 || keyCode > 57) && keyCode !== 46) {
    event.preventDefault()
  }
}

export const toFormData = (json) => {
  const formData = new FormData()

  Object.keys(json).forEach((key) => {
    const value = json[key]
    if (Array.isArray(value)) {
      value.forEach((item) => formData.append(key, JSON.stringify(item)))
    } else if (json[key] || json[key] === 0) {
      formData.append(key, json[key])
    }
  })
  return formData
}
