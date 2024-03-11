import styled from 'styled-components';
import { Box } from '@mui/material';

export const H1=styled.h1`
    margin-top: 35px;
    margin-bottom: 40px;
    color: #101522;
    font-size: 40px;   
    font-weight: 700;
    text-align: center;
`;

export const Hlabel=styled.div`
    margin-bottom: 40px;
    color: #22333b;
    font-size: 10px;   
    font-weight: 400;
    text-align: left;
`;

export const LendingRequestsList=styled.div`
    margin-bottom: 40px;
    color: #22333b;
    font-size: 10px;   
    font-weight: 400;
    text-align: left;
`;

export const H3=styled.div`
    margin-top: 60px;
    margin-bottom: 40px;
    color: #101522;
    font-size: 30px;   
    font-weight: 700;
    text-align: center;
`;

export const FileTitle=styled.div`
    margin-bottom: 5px;
    color: #101522;
    font-size: 17px;   
    font-weight: 700;
    font-family: 'Arial';
`;

export const Files=styled.div`
    margin-bottom: 5px;
    color: #101522;
    font-size: 15px;   
    font-weight: 200;
    font-family: 'Arial';
`;

export const BackgroundVideo = styled('video')({
    width: '100%', // Adjust as necessary
    height: 'auto', // Adjust height based on content
    objectFit: 'cover', // Cover the area without losing the aspect ratio
  });

  export const StyledBox = styled(Box)({
    display: 'flex',
    flexDirection: 'column',
  });