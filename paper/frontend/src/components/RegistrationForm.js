import React, { useState, useEffect } from 'react';
import { ref, set, database, push } from '../firebase';
import { getDatabase, get } from 'firebase/database';
import levenshtein from 'fast-levenshtein';
import useWeb3 from '../hooks/useWeb3';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import styles from '../styles/Registration.module.css';
import Select from '@mui/material/Select';
import MenuItem from '@mui/material/MenuItem';
import InputLabel from '@mui/material/InputLabel';
import FormControl from '@mui/material/FormControl';
import FormControlLabel from '@mui/material/FormControlLabel';
import Checkbox from '@mui/material/Checkbox';
import Alert from '@mui/material/Alert';
import Stack from '@mui/material/Stack';
import Web3 from 'web3';
import WarningIcon from '@mui/icons-material/Warning';
import IconButton from '@mui/material/IconButton';
import Tooltip from '@mui/material/Tooltip';
import LoadingButton from '@mui/lab/LoadingButton';
import SendIcon from '@mui/icons-material/Send';

const RegistrationForm = () => {
  const { web3, account, contract } = useWeb3();
  const [type, setType] = useState(''); 
  const [email, setEmail] = useState('');
  const [fullName, setFullName] = useState('');
  const [success, setSuccess] = useState(null);
  const [country, setCountry] = useState('');
  const [address, setAddress] = useState('');
  const [postCode, setPostcode] = useState('');
  const [city, setCity] = useState('');
  const [differentAccount, setDifferentAccount] = useState('');
  const [recoverable, setRecoverable] = useState(false);
  const typeOptions = ['Natural Person', 'Legal Entity'];
  const countries = ['Switzerland', 'Germany']; // Add more countries as needed
  var [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);


  useEffect(() => {
    setDifferentAccount(account || '');
  }, [account]);

  const checkName = async (name) => {
    const axios = require('axios');
    let data = JSON.stringify({
      "model": "gpt-3.5-turbo",
      "messages": [
        {
          "role": "user",
          "content": "Return a number in the range of 0 and 1, based on the likely hood that below name is fictional or real - 1 being fictional, 0 being real. Fictional names are names that come from movies, like Mickey Mouse or James Bond. If names from movies/series or any other entertainment are entered, you should return the number 1. It doesn't matter if you are uncertain, just give me a number, and only a number! \n" + name
        }
      ],
      "max_tokens": 3,
      "temperature": 0.5,
    });
    const apiKey = process.env.NEXT_PUBLIC_OPENAI_API_KEY;
    let config = {
      method: 'post',
      maxBodyLength: Infinity,
      url: 'https://api.openai.com/v1/chat/completions',
      headers: { 
        'Content-Type': 'application/json', 
        'Authorization': `Bearer ${apiKey}`
      },
      data : data
    };

    try {
      const response = await axios.request(config);
      const prob = JSON.stringify(response.data['choices'][0]['message']['content']);
      // console.log(prob);
      return JSON.stringify(prob);
    } catch (error) {
      console.log(error);
    }
  };

  const checkNameIsFictional = async (name) => {
    let isFictional = false;
    var result = await checkName(name);
    result = result.replace(/"/g, ''); // Remove extra quotes
    result = result.replace(/\\/g, '').replace(/"/g, ''); // Remove backslashes and quotes
    var floatResult = parseFloat(result); // Convert to float
    // console.log(floatResult);

    if (result > 0.91) {
      isFictional = true;
    } 
    return isFictional;
  };

  const checkSanctionsList = async (name) => {
    const db = getDatabase();
    const sanctionsListRef = ref(db, 'sanctions/');
    const snapshot = await get(sanctionsListRef);
    const sanctionsList = snapshot.val();
    const sanctionedNames = Object.values(sanctionsList).map(item => item.name);
    let isSanctioned = false;
    const maxAllowedDistance = 2;
  
    const lowerCaseName = name.toLowerCase(); // Convert user's name to lower case

    sanctionedNames.forEach(sanctionedName => {
      const lowerCaseSanctionedName = sanctionedName.toLowerCase(); // Convert sanctioned name to lower case
      const distance = levenshtein.get(lowerCaseName, lowerCaseSanctionedName);
      if (distance <= maxAllowedDistance) {
        isSanctioned = true;
      }
    });
    return isSanctioned;
  };
  
  const handleClick = async (e) => {
    setLoading(true);
    e.preventDefault();

    // Prevent form submission if nameError is not null
    const isFictional = await checkNameIsFictional(fullName);
    if (isFictional) {
      setLoading(false);
      setError('Name seems to be fictional, please use your real name.');
      return;
    }

    // Check sanctions list
    const isSanctioned = await checkSanctionsList(fullName);
    if (isSanctioned) {
      setLoading(false);
      setError('This name is on the sanctions list and cannot register.');
      return;
    }
  
    try {
      // Create a new user in the database with a unique ID
      const newUserRef = ref(database, 'users/');
      const newUser = push(newUserRef);
      await set(newUser, { type, fullName, email, address, postCode, city, country, differentAccount, recoverable });

      // register hash and address in smart contract
      if (recoverable) {
        const hash = Web3.utils.keccak256(fullName + address);
        try {
          await contract.methods.registerHash(hash).send({ from: account });
        }
        catch (error) {
          setLoading(false);
          setError('Registration failed, please approve the registration transaction with your wallet!');
          return;
        }
      }

      setLoading(false);
      // Reset form
      setType('');
      setFullName('');
      setEmail('');
      setCountry('');
      setAddress('');
      setPostcode('');
      setCity('');
      setCountry('');
      setError(null);
      setSuccess('Registration successful!');
    } catch (error) {
        setError(error.message);
    }
  };
  
  return (
    <div className={styles.container1}>
      <div className={styles.rectangle}>
        <h1>Registration</h1>
        <form onSubmit={handleClick}>
        <div>
          <p>
            Please read our registration agreement before registering! It can be found <a href="/Registration_Agreement_SCL_Professor.pdf" download style={{ textDecoration: 'underline' }}>here</a>.
          </p>
        </div>
        <div>
            <p>Type</p>
            <FormControl fullWidth>
              <InputLabel id="type-label">Type</InputLabel>
              <Select
                required
                labelId="type-label"
                id="type-select"
                value={type}
                onChange={(e) => setType(e.target.value)}
                sx={{ width: '100%' }}
                className={styles.customTextField}
              >
                {typeOptions.map((option) => (
                  <MenuItem key={option} value={option}>
                    {option}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </div>
          <div>
            <p>Name</p>
            <TextField
              required
              id="outlined-required"
              label="Name"
              value={fullName}
              onChange={(e) => setFullName(e.target.value)}
              className={styles.customTextField}
              sx={{ width: '100%' }}
            />
          </div>
          <div>
            <p>Email</p>
            <TextField
              required
              id="outlined-required"
              label="Email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className={styles.customTextField}
              sx={{ width: '100%' }}
            />
          </div>
          <div>
            <p>Address</p>
            <TextField
              required
              id="outlined-required"
              label="Address"
              value={address}
              onChange={(e) => setAddress(e.target.value)}
              className={styles.customTextField}
              sx={{ width: '100%' }}
            />
          </div>
          <div>
            <p>Post Code</p>
            <TextField
              required
              id="outlined-required"
              label="Post Code"
              value={postCode}
              onChange={(e) => setPostcode(e.target.value)}
              className={styles.customTextField}
              sx={{ width: '100%' }}
            />
          </div>
          <div>
            <p>City</p>
            <TextField
              required
              id="outlined-required"
              label="City"
              value={city}
              onChange={(e) => setCity(e.target.value)}
              className={styles.customTextField}
              sx={{ width: '100%' }}
            />
          </div>
          <div>
            <p>Country</p>
            <FormControl fullWidth>
              <InputLabel id="country-label">Country</InputLabel>
              <Select
                labelId="country-label"
                id="country-select"
                value={country}
                onChange={(e) => setCountry(e.target.value)}
                sx={{ width: '100%' }}
                className={styles.customTextField}
              >
                {countries.map((country) => (
                  <MenuItem key={country} value={country}>
                    {country}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </div>
          <div>
            <p>Polygon Address</p>
            <TextField
              required
              id="outlined-required"
              label=""
              value={differentAccount}
              onChange={(e) => setDifferentAccount(e.target.value)}
              className={styles.customTextField}
              sx={{ width: '100%' }}
            />
          </div>
          <div>
            <FormControlLabel 
              required control={<Checkbox sx={{ color: 'white' }}/>} 
              label="Switzerland is my only tax country" 
              sx={{ color: 'white' }}
            />
          </div>
          <div>
            <FormControlLabel 
              control={<Checkbox sx={{ color: 'white' }}/>} 
              label="I want my account to be recoverable" 
              sx={{ color: 'white' }}
              value={recoverable}
              onChange={(e) => setRecoverable(e.target.checked)}
            />
             <Tooltip title="By opting for this option, the Token Holder consents to grant partial authority over the account to the Issuer and Deputy." placement='top'>
                <IconButton>
                  <WarningIcon 
                    sx={{ color: 'white' }} />
                </IconButton>
              </Tooltip>
          </div>
          <LoadingButton
            type='submit'
            endIcon={<SendIcon />}
            loading={loading}
            loadingPosition="end"
            variant="contained"
            sx={{ backgroundColor: 'white', color: 'black', '&:hover': { backgroundColor: 'grey', }, width: '100%', mt: 2, mb: 2 }}
          >
            <span>Send</span>
          </LoadingButton>
          {error && 
            <Stack sx={{ width: '100%', mb: '15px' }} spacing={2}>
              <Alert severity="error">{ error }</Alert>
            </Stack>
          }
          {success &&
            <Stack sx={{ width: '100%', mb: '15px' }} spacing={2}>
                <Alert severity="success">{ success }</Alert>
            </Stack>
          }        
        </form>
      </div>
    </div>
  );
};

export default RegistrationForm;
