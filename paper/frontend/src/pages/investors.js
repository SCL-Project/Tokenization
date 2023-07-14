import React from 'react';
import UserPurchaseBox from '../components/UserPurchaseBox';
import AppBar from '../components/AppBar';
import StatusBar from '../components/StatusBar';

export default function Home() {
  return (
    <>
      <AppBar />
      <UserPurchaseBox />
      <StatusBar />
    </>  
  )
}