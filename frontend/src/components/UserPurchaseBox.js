import React, { useState, useEffect } from 'react';
import styles from '../styles/UserPurchaseBox.module.css';
import styless from '../styles/CompanyBox.module.css';
import Web3 from 'web3';
import abi from '../contracts/abi.json';
import Button from '@mui/material/Button';
import { styled } from '@mui/system';
import TextField from '@mui/material/TextField';
import MenuItem from '@mui/material/MenuItem';
import useWeb3 from '../hooks/useWeb3';
import Balance from './Balance';



const UserPurchaseBox = () => {
  const { web3, account, contract } = useWeb3();

  const [tokenPrice, setTokenPrice] = useState(0);
  const [amountInMatic, setamountInMatic] = useState('');
  const [amountInTokens, setAmountInTokens] = useState('');

  useEffect(() => {
    if (amountInMatic !== '') {
      setAmountInTokens(amountInMatic / tokenPrice);
    }
  }, [amountInMatic, tokenPrice]);

  useEffect(() => {
    if (amountInTokens !== '') {
      setamountInMatic(amountInTokens * tokenPrice);
    }
  }, [amountInTokens, tokenPrice]);

  const fetchTokenPrice = async () => {
    if (contract) {
      const price = await contract.methods.offeringPrice().call();
      const priceInMatic = web3.utils.fromWei(price.toString(), 'ether');
      setTokenPrice(parseFloat(priceInMatic));
    }
  };  

  useEffect(() => {
    fetchTokenPrice();
  }, [contract]);

  const buyTokens = async (amountInMatic) => {
    if (web3 && account && contract) {
      // Call the buyTokens function from your smart contract
      console.log('Buying tokens...');
      const roundedNumber = parseFloat(amountInMatic.toFixed(18));
      await contract.methods.buyTokens().send({ from: account, value: web3.utils.toWei(roundedNumber.toString(), 'ether') });
    } else {
      window.alert('Please connect to MetaMask and load the smart contract.');
    }
  };

  const CustomButton = styled(Button)({
    backgroundColor: '#D9D9D9;',
    color: '#000000',
    '&:hover': {
      backgroundColor: '#D9D9D8',
    },
    // Add any other custom styles here
  });

  const currencies = [
    {
      value: 'MATIC',
      label: '$',
    },
    {
      value: 'SCL',
      label: '€',
    },
  ];
  
  return (
    <div className={styles.container1}>
      <div className={styles.rectangle}>
        <h1>Company Name AG</h1>
        <Balance web3={web3} account={account} contract={contract} />
        <TextField
          id="filled-number"
          label="MATIC"
          type="number"
          InputLabelProps={{
              shrink: true,
          }}
          variant="filled"
          value={amountInMatic}
          onChange={(e) => setamountInMatic(e.target.value)}
          className={styles.customTextField}
        />
        <TextField
          id="filled-number"
          label="SCL"
          type="number"
          InputLabelProps={{
              shrink: true,
          }}
          variant="filled"
          value={amountInTokens}
          onChange={(e) => setAmountInTokens(e.target.value)}
          className={styles.customTextField}
          sx={{
            mt: 1,
          }}
        />
        <div className={styles.flexButton}>
        <Button 
          variant="contained"
          onClick={() => buyTokens(amountInMatic)}
          className={styles.button}
          sx={{                            
              width: '100%',
              mt: 1,                           
          }}>
          Buy
        </Button>
        </div>
      </div>
    </div>
  );
};

export default UserPurchaseBox;
