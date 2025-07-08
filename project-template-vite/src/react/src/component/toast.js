import toast from 'react-hot-toast'

//eslint-disable-next-line
export function useSuccessToast(msg) {
  const successToast = (msg) => {
    toast.success(msg, {
      position: 'top-center'
    })
  }

  return successToast
}

//eslint-disable-next-line
export function useErrorToast(msg) {
  const errorToast = (msg) => {
    toast.error(msg)
  }

  return errorToast
}
