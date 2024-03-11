import React from 'react';
import { Nav, NavbarContainer, NavLogo } from './NavbarElements'
import { animateScroll as scroll } from 'react-scroll';

const Navbar = ({toggle}) => {
    

    const toggleHome = () => {
        scroll.scrollToTop();
    }

  return (
        <>
            <Nav>
                <NavbarContainer>
                    <NavLogo to='/' onClick={toggleHome}>P2P-Lending</NavLogo>
                </NavbarContainer>
            </Nav>
        </>
    );
};

export default Navbar;