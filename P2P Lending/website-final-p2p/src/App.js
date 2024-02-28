import React from 'react';
import './App.css';
import {BrowserRouter as Router, Route, Routes } from 'react-router-dom'
import Home from './pages/home';
import LogIn from './pages/login'
import SignUp from './pages/signup';
import SignUp1 from './components/SignUp1';
import SignUp2 from './components/SignUp2';


function App() {
  return (
    <Router>
      <Routes>
        <Route path='/' element={<Home />} exact />
        <Route path='/login' element={<LogIn />} />
        <Route path='/signupP' element={<SignUp2 />} />
      </Routes>
    </Router>
  );
}

export default App;
