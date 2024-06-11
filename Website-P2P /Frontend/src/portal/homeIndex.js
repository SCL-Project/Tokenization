import React, { useEffect, useState } from 'react'
import Home from './HomePage/home'
import MarketPage from './MarketplacePage/MarketplacePage'

export default function HomeIndex() {
	const [isLoggedIn, setIsLoggedIn] = useState(false)

	const checkUserToken = () => {
		const userToken = localStorage.getItem('user-token')
		if (!userToken || userToken === 'undefined') {
			setIsLoggedIn(false)
		} else {
			setIsLoggedIn(true)
		}
	}

	useEffect(() => {
		checkUserToken()
	}, [isLoggedIn])

	if (isLoggedIn) {
		return <MarketPage/>
	} else {
		return <Home />
	}
}
