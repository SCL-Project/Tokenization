import React from 'react';
import Svg2 from '../../images/svg2.svg'

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
    Button
} from './Info03Elements';
/*import { FaTeamspeak } from 'react-icons/fa';*/



const InfoSection03 = () => {
  return (
    <>
        <InfoContainer id={'signup'}>
            <InfoWrapper>
                <InfoRow >
                    <Column1>
                        <TextWrapper>
                            <TopLine>JOIN OUR TEAM</TopLine>
                            <Heading>Creating an account is extremely easy</Heading>
                            <Subtitle >Get everything set up and ready in under 10 minutes. All you need to do is add your information and you are ready to go.</Subtitle>
                            <BtnWrap>
                                <Button 
                                to='/signupP'
                                smooth ={true}
                                duration={500}
                                spy={true}
                                exact='true'
                                offset={-80}
                                >Start Now</Button>
                            </BtnWrap>
                        </TextWrapper>
                    </Column1>
                    <Column2>
                        <ImgWrap>
                             <Img src={Svg2}/>
                        </ImgWrap>
                    </Column2>
                </InfoRow>
            </InfoWrapper>
        </InfoContainer>
    </>
  );
};

export default InfoSection03