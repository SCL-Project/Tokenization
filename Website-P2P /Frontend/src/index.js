import React from 'react'
import ReactDOM from 'react-dom/client'
import 'bootstrap/dist/css/bootstrap.min.css'
import './index.css'
import reportWebVitals from './reportWebVitals'
import { BrowserRouter, Route, Routes } from 'react-router-dom'
import Login from './auth/login/Login'
import Auth from './auth/Auth'
import App from './App'
import Register from './auth/register/Register'
import HomeIndex from './portal/homeIndex'

const root = ReactDOM.createRoot(document.getElementById('root'))
root.render(
	<React.StrictMode>
		<BrowserRouter basename={'/'}>
			<Routes>
				<Route path='/' element={<App />}>
					{/* If logged in, it will display MarketPlace */}
					{/* If he is not logged in, it will display HomePage */}
					<Route path='' element={<HomeIndex />} />
				</Route>

				<Route path='/auth' element={<Auth />}>
					<Route path='login' element={<Login />} />
				</Route>
				<Route path='/auth' element={<Auth />}>
					<Route path='register' element={<Register />} />
				</Route>
			</Routes>
		</BrowserRouter>
	</React.StrictMode>
)

reportWebVitals()
