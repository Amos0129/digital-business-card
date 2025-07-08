import Axios from 'axios'
import { LOGIN_ROUTE } from 'page/login/config'
import { NOT_FOUND_ROUTE } from 'page/error/config'
import reduxStore from 'config/store'
import { dispatchMembderInfo } from 'reducer/member-info'
import { compose } from 'utils/lambdas'

const jsonToB64 = compose(btoa, unescape, encodeURIComponent, JSON.stringify)

class PubClinet {
  get _PORT() {
    return window.location.hostname === 'localhost' ? '5566' : window.location.port
  }

  get _BASE_URL() {
    return `${window.location.protocol}//${window.location.hostname}:${this._PORT}`
  }

  get _SCOPE() {
    return 'pub'
  }

  constructor() {
    this._config = {
      baseURL: `${this._BASE_URL}/${this._SCOPE}`
    }

    if (process.env.NODE_ENV === 'development') {
      this._config.withCredentials = true
    }
  }

  _path(paths) {
    let url = ''
    paths.forEach((path) => (url += `/${path}`))
    return url
  }

  get proto() {
    if (!this._axios) {
      this._axios = Axios.create(this._config)
    }

    return this._axios
  }

  get(params, ...paths) {
    return this.getWith(params, {}, ...paths)
  }

  getWith(params, config = {}, ...paths) {
    config.params = params
    return this.proto.get(this._path(paths), config)
  }

  post(params, ...paths) {
    return this.postWith(params, {}, ...paths)
  }

  postWith(params, config = {}, ...paths) {
    return this.proto.post(this._path(paths), params, config)
  }

  put(params, ...paths) {
    return this.putWith(params, {}, ...paths)
  }

  putWith(params, config = {}, ...paths) {
    return this.proto.put(this._path(paths), params, config)
  }

  delete(params, ...paths) {
    return this.deleteWith(params, {}, ...paths)
  }

  deleteWith(params, config = {}, ...paths) {
    config.params = params
    return this.proto.delete(this._path(paths), config)
  }

  download(params, fileName, ...paths) {
    return this.getWith(params, { responseType: 'blob' }, ...paths).then((resp) => {
      if (window.navigator.msSaveOrOpenBlob) {
        window.navigator.msSaveBlob(resp.data, fileName)
      } else {
        const tempDom = document.createElement('a')

        tempDom.id = 'downloadTemp'
        tempDom.class = 'hidden'
        tempDom.href = URL.createObjectURL(resp.data)
        tempDom.download = fileName
        document.body.appendChild(tempDom)
        tempDom.click()
        document.body.removeChild(tempDom)
        setTimeout(() => window.URL.revokeObjectURL(tempDom.href), 100)
      }
    })
  }
}

class PrivClient extends PubClinet {
  get _SCOPE() {
    return 'priv'
  }

  // eslint-disable-next-line
  get proto() {
    try {
      this._guard()

      if (!this._axios) {
        this._config.headers = { Pragma: 'no-cache' }
        this._axios = Axios.create(this._config)
        this._interceptor()
      }
      // todo: 配合後端修改csrf-token名稱
      this._axios.defaults.headers.common['x-template-csrf'] = jsonToB64(reduxStore.getState().memberInfo)

      return this._axios
      //eslint-disable-next-line
    } catch (e) {
      window.location.href = '/'
    }
  }

  _guard() {
    if (!Object.keys(reduxStore.getState().memberInfo).length) {
      throw '未登入'
    }
  }

  _interceptor() {
    this._axios.interceptors.response.use(
      (resp) => resp,
      (error) => {
        switch (error.response.status) {
          case 403:
            reduxStore.dispatch(dispatchMembderInfo({}))
            window.location.href = LOGIN_ROUTE.path
            return Promise.stop()
          case 404:
          case 500:
            window.location.href = NOT_FOUND_ROUTE.path
            return Promise.stop()
          default:
            return Promise.reject(error)
        }
      }
    )
  }
}

export const pubClient = new PubClinet()
export const privClient = new PrivClient()
