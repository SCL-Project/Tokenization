import React from 'react';
import {
    FooterContainer,
    FooterWrap,
    FooterLinksContainer,
    FooterLinksWrapper,
    FooterLinkItems,
    FooterLinkTitle,
    FooterLink
} from './FooterElements';

const Footer = () => {
  return (
    <FooterContainer>
        <FooterWrap>
            <FooterLinksContainer>
                <FooterLinksWrapper>
                    <FooterLinkItems>
                        <FooterLinkTitle>About us</FooterLinkTitle>
                        <FooterLink to='/login'>Blockchain</FooterLink>
                        <FooterLink to='/login'>Testimonials</FooterLink>
                        <FooterLink to='/login'>Investors</FooterLink>
                        <FooterLink to='/login'>Terms of Services</FooterLink>
                    </FooterLinkItems>
                    <FooterLinkItems>
                        <FooterLinkTitle>Contact Us</FooterLinkTitle>
                        <FooterLink to='/login'>Contact</FooterLink>
                        <FooterLink to='/login'>Support</FooterLink>
                        <FooterLink to='/login'>Destinations</FooterLink>
                        <FooterLink to='/login'>Sponsorship</FooterLink>
                    </FooterLinkItems>
                </FooterLinksWrapper>
                <FooterLinksWrapper>
                    <FooterLinkItems>
                        <FooterLinkTitle>Videos</FooterLinkTitle>
                        <FooterLink to='/login'>Submit Video</FooterLink>
                        <FooterLink to='/login'>Ambassandors</FooterLink>
                        <FooterLink to='/login'>Agency</FooterLink>
                        <FooterLink to='/login'>Influencer</FooterLink>
                    </FooterLinkItems>
                    <FooterLinkItems>
                        <FooterLinkTitle>Social Media</FooterLinkTitle>
                        <FooterLink to='/login'>Instagram</FooterLink>
                        <FooterLink to='/login'>Facebook</FooterLink>
                        <FooterLink to='/login'>Youtube</FooterLink>
                        <FooterLink to='/login'>Twitter</FooterLink>
                    </FooterLinkItems>
                </FooterLinksWrapper>
            </FooterLinksContainer>
        </FooterWrap>
    </FooterContainer>
  )
}

export default Footer