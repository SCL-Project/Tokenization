import React, {useState} from 'react';
import Navbar from './Navbar';
import Sidebar from './Sidebar';
import HeroSection from './HeroSection';
import InfoSection01 from './InfoSection01';
import InfoSection03 from './InfoSection03';
import InfoSection02 from './InfoSection02';
import Footer from './Footer';


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
      <InfoSection01 />
      <InfoSection02 />
      <InfoSection03 />
      <Footer />
    </>
  );
};

export default Home