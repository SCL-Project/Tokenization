import React from 'react'
import { NavBtn, NavBtnLinks } from  '../../../portal/HomePage/Navbar/NavbarElements'
import { Nav, NavLogo, NavbarContainer } from '../../auth.elements/navbar/AuthNavbarElements'
import { NavLink } from 'react-router-dom'

const LoginNavbar = () => {
	const handleLogout = () => {
		localStorage.setItem('user-token', undefined)
		window.location.reload()
	}

	return (
		<>
			<Nav>
				<NavbarContainer>
					<NavLogo>
						<NavLink to='/' style={{ all: 'unset', cursor: 'pointer' }}>
							P2P-Lending
						</NavLink>
					</NavLogo>
					<NavBtn>
						<NavBtnLinks onClick={handleLogout}>Log out</NavBtnLinks>
					</NavBtn>
				</NavbarContainer>
			</Nav>
		</>
	)
}

export default LoginNavbar
