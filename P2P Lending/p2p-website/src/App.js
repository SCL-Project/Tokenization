import React from 'react';
import './App.css';
import {BrowserRouter as Router, Route, Routes } from 'react-router-dom'
import Home from './pages';
import LogIn from './pages/login';


function App() {
  return (
    <Router>
      <Routes>
        <Route path='/' element={<Home />} exact />
        <Route path='/login' element={<LogIn />} />
      </Routes>
    </Router>
  );
}

export default App;
