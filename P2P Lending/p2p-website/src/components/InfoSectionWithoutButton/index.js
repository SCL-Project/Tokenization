import React from 'react';
import videoFile from '../../videos/video.mp4'

import { 
    InfoContainer, 
    InfoWrapper,
    InfoRow,
    Column1,
    Column2,
    TextWrapper,
    TopLine,
    Heading,
    Subtitle, 
    ImgWrap
} from './InfowbElements';




const InfoSectionWithoutButton = ({
    $lightBg, 
    id, 
    $imgStart, 
    topLine, 
    $lightText, 
    headline, 
    $darkText, 
    description,  
}) => {
  return (
    <>
        <InfoContainer $lightBg={$lightBg} id={id}>
            <InfoWrapper>
                <InfoRow $imgStart={$imgStart}>
                    <Column1>
                        <TextWrapper>
                            <TopLine>{topLine}</TopLine>
                            <Heading $lightText={$lightText}>{headline}</Heading>
                            <Subtitle $darkText={$darkText}>{description}</Subtitle>
                        </TextWrapper>
                    </Column1>
                    <Column2>
                    <ImgWrap>
                        <video width="100%" controls>
                        <source src={videoFile} type="video/mp4" />
                        </video>
                    </ImgWrap>
                    </Column2>
                </InfoRow>
            </InfoWrapper>
        </InfoContainer>
    </>
  );
};

export default InfoSectionWithoutButton
