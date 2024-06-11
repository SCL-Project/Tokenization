import React from 'react'
import { NavBtn, NavBtnLinks } from  '../../../portal/HomePage/Navbar/NavbarElements'
import { Nav, NavLogo, NavbarContainer, NavBarButtons } from './AuthNavbarElements'
import { NavLink } from 'react-router-dom'

const AuthNavbar = () => {
	return (
		<>
			<Nav>
				<NavbarContainer>
					<NavLogo>
						<NavLink to='/' style={{ all: 'unset', cursor: 'pointer' }}>
							P2P-Lending
						</NavLink>
					</NavLogo>
					<NavBarButtons>
						<NavBtn>
							<NavBtnLinks to={'/auth/login'}>Log In</NavBtnLinks>
						</NavBtn>
						<NavBtn>
							<NavBtnLinks style={{ marginLeft: 20 }} to={'/auth/register'}>
								Sign Up
							</NavBtnLinks>
						</NavBtn>
					</NavBarButtons>
				</NavbarContainer>
			</Nav>
		</>
	)
}

export default AuthNavbar
