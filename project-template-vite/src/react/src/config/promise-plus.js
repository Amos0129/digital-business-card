;(() => {
  const HEIMDALL = {}

  Promise.stop = function () {
    return HEIMDALL
  }
  Promise.prototype._then = Promise.prototype.then
  Promise.prototype.then = function (resolve, reject) {
    return this._then(function (val) {
      if (val !== HEIMDALL) {
        return typeof resolve === 'function' ? resolve(val) : val
      } else {
        return HEIMDALL
      }
    }, reject)
  }
})()
