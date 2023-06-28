// Header.js
import React from 'react';
import styles from '../styles/header.module.css';
import TextField from '@mui/material/TextField';
import SearchIcon from '@mui/icons-material/Search';
import InputAdornment from '@mui/material/InputAdornment';
import { useState, useEffect } from 'react';
import Web3 from 'web3';

const Header = () => {
    const [web3, setWeb3] = useState(null);
    const [account, setAccount] = useState(null);

    useEffect(() => {
        if (window.ethereum) {
        setWeb3(new Web3(window.ethereum));
        } else {
        console.log('Please install MetaMask or another Ethereum wallet provider.');
        }
    }, []);

    const connectWallet = async () => {
        if (!web3) return;

        try {
        const accounts = await web3.eth.requestAccounts();
        console.log('Connected account:', accounts[0]);
        setAccount(accounts[0]); // Save the connected account
        } catch (error) {
            console.error('Error connecting to wallet:', error);
        }
    };

    // Function to truncate the address for better readability
    const truncateAddress = (address) => {
        if (!address) return '';
        return address.slice(0, 6) + '...' + address.slice(-4);
    };

    return (
        <header className={styles.header}>
            <div className={styles.logo}>
                <img src="/SCLLogo.svg" alt="Logo" />
            </div>
            <TextField 
                id="outlined-search" 
                label="Search for company" 
                type="search"
                sx={{
                    width: '350px',
                    height: '40px',
                    '@media only screen and (max-width: 767px)': {
                        display: 'none',
                      },
                    // set background color
                    backgroundColor: 'rgba(0, 104, 55, 1)',
                    // Set the text color
                    color: 'rgba(255, 255, 255, 0.5)',
                    '& .MuiOutlinedInput-root': {
                        height: '40px',
                        // Set the border color
                        '& fieldset': {
                            borderColor: 'rgba(255, 255, 255, 0.5)',
                        },
                        '&:hover fieldset': {
                            borderColor: 'white',
                        },
                        '&.Mui-focused fieldset': {
                            borderColor: 'white',
                        },
                    },
                    // Set the placeholder text color
                    '& .MuiInputLabel-outlined': {
                    color: 'rgba(255, 255, 255, 0.5)',
                    },
                    '& .MuiInputLabel-outlined.Mui-focused': {
                    color: 'rgba(255, 255, 255, 0.5)',
                    },
                    '& .MuiOutlinedInput-input': {
                    // Set the input text color
                    color: 'white',
                    },
                }}
                InputProps={{
                startAdornment: (
                    <InputAdornment position="start" sx={{ color: 'rgba(255, 255, 255, 0.5)' }}>
                        <SearchIcon color="inherit" />
                    </InputAdornment>
                    ),
                }}
            />
            <div className={styles.connectWallet}>
                {/* JSX conditionals: condition ? expressionIfTrue : expressionIfFalse */}
                {account ? (
                <div>{truncateAddress(account)}</div>
                ) : (
                <button onClick={connectWallet}>
                    <img src="/ConnectWallet.svg" alt="connect wallet" />
                </button>
                )}
            </div>
        </header>
    );
};

export default Header;
