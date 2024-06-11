import React from 'react'
import { Routes, Route } from 'react-router-dom'
import Marketplace from './Marketplace/index'
import TokenTransfer from '../TokenTransfer'

const MarketPage = () => {
	return (
		<>
			<Routes>
				<Route path='/' element={<Marketplace />} exact />
				<Route path='/grant-credit/:borrowerAddress/:amount/:period' element={<TokenTransfer />} />
			</Routes>
		</>
	)
}

export default MarketPage
