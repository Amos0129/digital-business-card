import 'config/promise-plus'
import reduxStore from 'config/store'
import App from 'layout/app'
import { createRoot } from 'react-dom/client'
import { Toaster } from 'react-hot-toast'
import { Provider as ReduxProvider } from 'react-redux'
import { BrowserRouter } from 'react-router-dom'
import 'scss/main.scss'

const root = createRoot(document.getElementById('root'))

root.render(
  <BrowserRouter basename='/'>
    <ReduxProvider store={reduxStore}>
      <App />
      <Toaster />
    </ReduxProvider>
  </BrowserRouter>
)
