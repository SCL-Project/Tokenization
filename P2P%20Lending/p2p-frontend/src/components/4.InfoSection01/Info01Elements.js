import styled from 'styled-components';
import {Link} from 'react-router-dom';


export const InfoContainer = styled.div`
    color: #fff;
    background: #7393B3;
    
    
    @media screen and (max-width: 768px) {
        padding: 100px 0;
    }
`;

export const InfoWrapper = styled.div`
    display: grid;
    z-index: 1;
    height: 860px;
    width: 100%;
    max-width: 1100px;
    margin-left: auto;
    margin-right: auto;
    padding: 0 24px;
    justify-content: center;
`;

export const InfoRow = styled.div`
    display: grid;
    grid-auto-columns: minmax(auto, 1fr);
    align-items: center;
    grid-template-areas: 'col1 col2' ;

    @media screen and (max-width: 768px) {
        grid-template-areas: 'col1 col2' ;
    }
`;

export const Column1 = styled.div`
    margin-bottom: 15px;
    padding: 0 15px;
    grid-area: col1;
`;

export const Column2 = styled.div`
    margin-bottom: 15px;
    padding: 0 15px;
    grid-area: col2;
`;

export const TextWrapper = styled.div`
    max-width: 540px; 
    padding-top: 0;
    padding-bottom: 60px;   
`;

export const TopLine = styled.p`
    color: #fff;
    font-size: 16px;
    line-height: 16px;
    font-weight: 700;
    letter-spacing: 1.4px;
    text-transform: uppercase;
    margin-bottom: 16px;
`;

export const Heading = styled.h1`
    margin-bottom: 24px;
    font-size: 48px;
    line-height: 1.1;
    font-weight: 600;
    color: #010606;

    @media screen and (max-width: 480px) {
        font-size: 32px;
    }
`; 

export const Subtitle = styled.p`
    max-width: 440px;
    margin-bottom: 35px;
    font-size: 18px;
    line-height: 24px;
    color: #fff;
`;


export const BtnWrap = styled.nav`
    display: flex;
    align-items: center;
    justify-content: flex-start;

    @media screen and (max-width: 768px) {
        display: flex;
    }
`;

export const Button = styled(Link)`
    border-radius: 50px;
    background: #010606;
    white-space: nowrap;
    padding: 14px 48px;
    color: #fff;
    font-size: 16px;
    outline: none;
    border: none;
    cursor: pointer;
    transition: all 0.2s ease-in-out;
    text-decoration: none;
    /*text-decoration: none;*/

    &:hover {
        transition: all 0.2s ease-in-out;
        background: #fff;
        color: #010606;
    }
`;

export const ImgWrap  = styled.div`
    max-width: 555px;
    height: 100%;
`;

export const Img = styled.img`
    width: 100%;
    margin: 0 0 10px 0;
    padding-right: 0;
`;

