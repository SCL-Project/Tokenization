import React, {useState} from 'react';
import Navbar from '../components/1.Navbar';
import Sidebar from '../components/2.Sidebar';
import HeroSection from '../components/3.HeroSection';
import InfoSection01 from '../components/4.InfoSection01';
import InfoSection03 from '../components/6.InfoSection03';
import InfoSection02 from '../components/5.InfoSection02';
import Footer from '../components/7.Footer';


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