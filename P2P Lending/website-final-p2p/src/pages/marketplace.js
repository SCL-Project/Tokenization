import React from 'react'
import { Routes, Route } from 'react-router-dom';
import Marketplace from '../components/Marketplace'
import Footer from '../components/7.Footer'
import NavbarMarketplace from '../components/NavbarMarketplace'
import TokenTransfer from '../components/TokenTransfer';

const MarketPage = () => {
  return (
    <>
      <NavbarMarketplace/>
      <Routes>
      <Route path="/" element={<Marketplace />} exact />
      <Route path="/grant-credit/:borrowerAddress/:amount/:period" element={<TokenTransfer />} />
      </Routes>
      <Footer/>
    </>
  );
};

export default MarketPage;