class RSA {
  _arrayBufferToBase64(buffer) {
    let result = ''
    new Uint8Array(buffer).forEach((val) => {
      result += String.fromCharCode(val)
    })

    return window.btoa(result)
  }

  _stringToArrayBuffer(str) {
    const buf = new ArrayBuffer(str.length)
    const bufView = new Uint8Array(buf)
    for (let i = 0, strLen = str.length; i < strLen; i++) {
      bufView[i] = str.charCodeAt(i)
    }
    return buf
  }

  _importPubKey(b64Key) {
    const binaryDerString = window.atob(b64Key)

    return window.crypto.subtle.importKey(
      'spki',
      this._stringToArrayBuffer(binaryDerString),
      { name: 'RSA-OAEP', hash: 'SHA-256' },
      true,
      ['encrypt']
    )
  }

  encrypt(b64Key, plainText) {
    const enText = new TextEncoder().encode(plainText)

    return this._importPubKey(b64Key)
      .then((pubKey) => window.crypto.subtle.encrypt({ name: 'RSA-OAEP' }, pubKey, enText))
      .then((cipher) => this._arrayBufferToBase64(cipher))
  }
}

export const rsa = new RSA()
