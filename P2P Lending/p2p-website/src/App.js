import React from 'react';
import './App.css';
import {BrowserRouter as Router, Route, Routes } from 'react-router-dom'
import Home from './pages';
import LogIn from './pages/login';
import SignUp from './components/Signup';


function App() {
  return (
    <Router>
      <Routes>
        <Route path='/' element={<Home />} exact />
        <Route path='/login' element={<SignUp />} />
      </Routes>
    </Router>
  );
}

export default App;

/*<Route path='/login' element={<LogIn />} />*/