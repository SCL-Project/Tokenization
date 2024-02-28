import React from 'react'
import Marketplace from '../components/Marketplace'
import Footer from '../components/Footer'
import NavbarMarketplace from '../components/NavbarMarketplace'

const marketplacepage = () => {
  return (
    <>
      <NavbarMarketplace/>
      <Marketplace/>
      <Footer/>
    </>
  )
}

export default marketplacepage