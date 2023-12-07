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
import { set } from 'firebase/database';
import LoadingButton from '@mui/lab/LoadingButton';

const UserPurchaseBox = () => {
  const { web3, account, contract } = useWeb3();
  const [loading, setLoading] = useState(false);

  const [tokenPrice, setTokenPrice] = useState(0);
  const [amountInMatic, setAmountInMatic] = useState('');
  const [amountInTokens, setAmountInTokens] = useState('');

  let [tokenBalance, setTokenBalance] = useState(0);
  let [shareBalance, setShareBalance] = useState(0);
  let [fractionsBalance, setFractionsBalance] = useState(0);

  const fetchTokenBalance = async () => {
    if (!account || !contract) return;
    try {
      const balance = await contract.methods.balanceOf(account).call();
      const tokenBal = balance / 10 ** 18;
      const shareBal = Math.floor(tokenBal);
      const fractionsBal = parseFloat((tokenBal - shareBal).toFixed(4));
      setTokenBalance(tokenBal);
      setShareBalance(shareBal);
      setFractionsBalance(fractionsBal);
      setAmountInTokens('');
      setAmountInMatic('');
    } catch (error) {
      console.error('Error fetching token balance:', error);
    }
  }; 

  useEffect(() => {
    if (amountInMatic !== '') {
      setAmountInTokens(amountInMatic / tokenPrice);
    }
  }, [amountInMatic, tokenPrice]);

  useEffect(() => {
    if (amountInTokens !== '') {
      setAmountInMatic(amountInTokens * tokenPrice);
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

  useEffect(() => {
    fetchTokenBalance();
  }, [contract]);

  const buyTokens = async (amountInMatic) => {
    setLoading(true);
    if (web3 && account && contract) {
      try {
        const roundedNumber = parseFloat(amountInMatic.toFixed(18));
        await contract.methods.buyTokens().send({ from: account, value: web3.utils.toWei(roundedNumber.toString(), 'ether') });
        fetchTokenBalance();
      } catch (error) {
        console.error(error);
      }
    } else {
      window.alert('Please connect to MetaMask.');
    } 
    setLoading(false);
  }; 
  
  return (
    <div className={styles.container1}>
      <div className={styles.rectangle}>
        <h1>Company Name AG</h1>
        <Balance web3={web3} account={account} contract={contract} tokenBalance={tokenBalance} shareBalance={shareBalance} fractionsBalance={fractionsBalance} />
        <TextField
          id="filled-number"
          label="MATIC"
          type="number"
          InputLabelProps={{
              shrink: true,
          }}
          variant="filled"
          value={amountInMatic}
          onChange={(e) => setAmountInMatic(e.target.value)}
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
        <LoadingButton
            onClick={() => buyTokens(amountInMatic)}
            loading={loading}
            loadingPosition="end"
            variant="contained"
            sx={{ backgroundColor: 'white', color: 'black', '&:hover': { backgroundColor: 'grey', }, width: '100%', mt: 1 }}
          >
            <span>Buy</span>
        </LoadingButton>
        <div>
          <p className={styles.finePrint}>Before or when you purchase tokens, you are required to register. Please see the registration page for more details!</p>
        </div>
      </div>
    </div>
  );
};

export default UserPurchaseBox;
