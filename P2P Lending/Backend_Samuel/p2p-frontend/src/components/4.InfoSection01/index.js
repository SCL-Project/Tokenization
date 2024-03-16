import React from 'react';
import Svg1 from '../../images/svg1.svg';


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
    BtnWrap,
    ImgWrap,
    Img,
    Button,
} from './Info01Elements';
/*import { FaTeamspeak } from 'react-icons/fa';*/



const InfoSection01 = () => {
  return (
    <>
        <InfoContainer id={'about'}>
            <InfoWrapper>
                <InfoRow >
                    <Column1>
                        <TextWrapper>
                            <TopLine>Smart Contract Lab</TopLine>
                            <Heading>About Us</Heading>
                            <Subtitle >We are a group of dedicated students from the Student Association SCL at the University of Zurich, delving into the innovative world of blockchain technology. Within our research into tokenization, we have created a peer-to-peer (P2P) lending platform, leveraging the power and security of blockchain.</Subtitle>
                            <BtnWrap>
                                <Button
                                to='home'
                                smooth ={true}
                                duration={500}
                                spy={true}
                                exact='true'
                                offset={-80}
                                >Learn more about SCL</Button>
                            </BtnWrap>
                        </TextWrapper>
                    </Column1>
                    <Column2>
                        <ImgWrap>
                             <Img src={Svg1}/>
                        </ImgWrap>
                    </Column2>
                </InfoRow>
            </InfoWrapper>
        </InfoContainer>
    </>
  );
};

export default InfoSection01