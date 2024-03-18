import styled from 'styled-components';
import {Link} from 'react-router-dom';

export const Container = styled.div`
    min-height: 100vh; /*692px*/
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    top: 0;
    z-index: 0;
    overflow: hidden;
    background: linear-gradient(
        108deg, 
        rgba(1, 147, 86, 1) 0%, 
        rgba(10, 201, 122, 1) 100%
        );
`;

export const TextWrap  = styled.div`
    height: 100%;
    display: flex;
    flex-direction: column;
    justify-content: center;
    padding: 20px;

    @media screen and (max-width: 480px) {
        padding: 10px;
    }
`;


export const Icon = styled(Link)`
    margin-left: 32px;
    margin-top: 32px;
    margin-bottom: 10px; /*Added that*/
    text-decoration: none;
    color: #fff;
    font-weight: 700;
    font-size: 32px;

    @media screen and (max-width: 480px) {
        margin-left: 16px;
        margin-top: 8px;
    }
`;
