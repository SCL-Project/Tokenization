import styled from 'styled-components'
import { Link as LinkR } from 'react-router-dom'

export const Nav = styled.nav`
    background-color: #101522;
    height: 80px;
    display: flex;
    justify-content: center;
    align-items: center;
    font-size: 1rem;
    z-index: 10;

    @media screen and (max-width: 960px) {
        transition: 0.8s all ease;
    }
`

export const NavbarContainer = styled.div`
    display: flex;
    justify-content: space-between;
    height: 80px;
    z-index: 1;
    width: 100%;
    padding: 0 24px;
    max-width: 1100px;
`

export const NavLogo = styled(LinkR)`
    color: #fff;
    justify-content: flex-start;
    cursor: pointer;
    font-size: 1.5rem;
    display: flex;
    align-items: center;
    margin-left: 24px;
    font-weight: bold;
    text-decoration: none;
    z-index: 2;
    `

export const VideoBg = styled.video`
    width: 100%;
    height: 15%;
    -o-object-fit: cover;
    object-fit: cover;
    background: #232a34;
    position: absolute;
    top: 0;
    left: 0;
    z-index: 0; // Ensure it's behind the content

    &::after {
    content: "";
    position: absolute;
    top: 0;
    right: 0;
    bottom: 0;
    left: 0;
    background: linear-gradient(to bottom, rgba(255, 255, 255, 0.5), transparent);
    z-index: -1; // Ensure it's above the video but below the content
    }
`;