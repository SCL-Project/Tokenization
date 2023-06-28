import React from 'react';
import Company from '../components/Company';
import AppBar from '../components/AppBar';
import StatusBar from '../components/StatusBar';

export default function CompanyView() {
  return (
    <>
      <AppBar />
      <Company />
      <StatusBar />
    </>  
  )
}