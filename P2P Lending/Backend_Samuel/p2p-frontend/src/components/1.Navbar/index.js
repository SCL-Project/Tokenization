import React from 'react';
import {FaBars} from 'react-icons/fa';
import { animateScroll as scroll } from 'react-scroll';
import {
    Nav, 
    NavbarContainer,
    NavLogo,
    MobileIcon,
    NavMenu,
    NavItem,
    NavLinks,
    NavBtn,
    NavBtnLinks
} from './NavbarElements';


const Navbar = ({toggle}) => {
    

    const toggleHome = () => {
        scroll.scrollToTop();
    }

  return (
    <>
        <Nav>
            <NavbarContainer>
                <NavLogo to='/' onClick={toggleHome}>P2P-Lending</NavLogo>
                <MobileIcon onClick={toggle}>
                    <FaBars />
                </MobileIcon>
                <NavMenu>
                    <NavItem>
                        <NavLinks to='about'
                        smooth={true} duration={500} spy={true} exact='true' offset={-80}
                        >About</NavLinks>
                    </NavItem>
                    <NavItem>
                        <NavLinks to='discover'
                        smooth={true} duration={500} spy={true} exact='true' offset={-80}
                        >Discover</NavLinks>
                    </NavItem>
                    <NavItem>
                        <NavLinks to='signup'
                        smooth={true} duration={500} spy={true} exact='true' offset={-80}
                        >Sign Up</NavLinks>
                    </NavItem>
                </NavMenu>
                <NavBtn>
                    <NavBtnLinks to="/login">Log In</NavBtnLinks>
                </NavBtn>
            </NavbarContainer>
        </Nav>
    </>
  )
}

export default Navbar