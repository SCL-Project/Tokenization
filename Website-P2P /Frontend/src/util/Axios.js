import axios from 'axios';

// Create an instance of axios with custom configurations
const instance = axios.create({
  baseURL: 'http://localhost:4000', // Adjust the base URL according to your API endpoint
  timeout: 5000, // Adjust the timeout as needed
});

// Add a request interceptor to include the user token in all requests
instance.interceptors.request.use(
  config => {
    // Retrieve user token from local storage
    const userToken = localStorage.getItem('user-token');
    console.log("interceptor fired")

    // Set the token in the request headers if it exists
    if (userToken) {
      config.headers.Authorization = `Bearer ${userToken}`;
    }

    return config;
  },
  error => {
    // Handle request errors
    return Promise.reject(error);
  }
);

export default instance;
