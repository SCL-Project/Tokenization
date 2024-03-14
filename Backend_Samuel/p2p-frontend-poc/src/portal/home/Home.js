import axios from '../../util/Axios'
import React, { useState, useEffect } from 'react';
import { Container } from 'react-bootstrap';

const Home = () => {
  // State to store user data
  const [userData, setUserData] = useState(null);

  useEffect(() => {
    // Fetch user data from the backend API
	axios.get('/user')
    .then(response => {
      // Update user data state with the received data
      setUserData(response.data);
    })
    .catch(error => {
      console.error('Error fetching user data:', error);
    });
  }, []); // Run this effect only once after the component mounts

  return (
    <React.Fragment>
      <Container className='py-5'>
        <h3 className='fw-normal'>Welcome Home.</h3>
        {userData && (
          <p>Hello {userData.firstname} {userData.lastname}</p>
        )}
      </Container>
    </React.Fragment>
  );
};

export default Home;
