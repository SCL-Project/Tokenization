import React, {useState} from 'react';
import Video from '../../videos/video.mp4';
import { Button } from '../ButtonElements';
import { 
  HeroContainer, 
  HeroBg, 
  VideoBg,
  HeroContent,
  HeroH1,
  HeroP,
  HeroBtnWrapper,
  ArrowForward,
  ArrowRight,
  VideoBgWhite
} from './HeroElements';

const HeroSection = () => {
  const [hover, setHover]= useState(false)

  const onHover = () => {
    setHover(!hover)
  }

  return (
    <HeroContainer>
        <HeroBg>
            <VideoBg autoPlay loop muted src={Video} type='video/mp4' />
            <VideoBgWhite />
        </HeroBg>
        <HeroContent>
          <HeroH1>Pocket-Sized Lending for Students 
            </HeroH1>
          <HeroP>Sign up for a new account today and transform student lives with just a few clicks. 
            Your small contribution are the key to unlocking someone's big dream.</HeroP>
          <HeroBtnWrapper>
            <Button to='signup' onMouseEnter={onHover} onMouseLeave={onHover}
            >Get started {hover ? <ArrowForward /> : <ArrowRight />}
            </Button>
          </HeroBtnWrapper>
        </HeroContent>
    </HeroContainer>
  )
}

export default HeroSection