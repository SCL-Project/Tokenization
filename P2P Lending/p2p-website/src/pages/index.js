import React, {useState} from 'react'
import Navbar from '../components/Navbar'
import Sidebar from '../components/Sidebar'
import HeroSection from '../components/HeroSection';
import InfoSection from '../components/InfoSection';
import { homeObjOne, homeObjThree, } from '../components/InfoSection/Data';
import InfoSectionWithoutButton from '../components/InfoSectionWithoutButton';
import { homeObjTwo } from '../components/InfoSectionWithoutButton/Data';
import Footer from '../components/Footer';

const Home = () => {
    const[isOpen, setIsOpen] = useState(false);

    const toggle = () => {
        setIsOpen(!isOpen);
    };



  return (
    <>
      <Navbar toggle={toggle}/>
      <Sidebar isOpen={isOpen} toggle={toggle} />
      <HeroSection />
      <InfoSection {...homeObjOne}/>
      <InfoSectionWithoutButton {...homeObjTwo}/>
      <InfoSection {...homeObjThree}/>
      <Footer />
    </>
  );
};

export default Home
