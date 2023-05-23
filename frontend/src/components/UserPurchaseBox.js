import React, { useState, useEffect } from 'react';
import styles from '@/styles/UserPurchaseBox.module.css';
import Web3 from 'web3';
import abi from '../contracts/abi.json';


const UserPurchaseBox = () => {
  const [web3, setWeb3] = useState(null);
  const [account, setAccount] = useState(null);
  const [contract, setContract] = useState(null);
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

  const loadWeb3AndBlockchainData = async () => {
    if (window.ethereum) {
      window.web3 = new Web3(window.ethereum);
      await window.ethereum.enable();
      const web3 = window.web3;
      setWeb3(web3);

      // Load the current user's account
      const accounts = await web3.eth.getAccounts();
      setAccount(accounts[0]);

      // Load the smart contract
      const contractAddress = '0x5bfcC7c3e81D40e73934BEc18C6032c6a769f791';
      const contract = new web3.eth.Contract(abi, contractAddress);
      setContract(contract);
    } else {
      window.alert('Please install MetaMask!');
    }
  };

  useEffect(() => {
    loadWeb3AndBlockchainData();
  }, []);

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
      await contract.methods.buyTokens().send({ from: account, value: web3.utils.toWei(amountInMatic.toString(), 'ether') });
    } else {
      window.alert('Please connect to MetaMask and load the smart contract.');
    }
  };
  

  return (
    <div>
        <div className={styles.rectangle}>
            <h1>Company Name AG</h1>
            <input
              type="number"
              value={amountInMatic}
              onChange={(e) => setamountInMatic(e.target.value)}
              className={styles.box0}
            />
            <img src="/CurSelector.svg" alt="Logo" className={styles.CurSelector0} />
            <input
              type="number"
              value={amountInTokens}
              onChange={(e) => setAmountInTokens(e.target.value)}
              className={styles.box1}
            />
            <img src="/CurSelector1.svg" alt="Logo" className={styles.CurSelector1} />
            <button onClick={() => buyTokens(amountInMatic)} className={styles.buy}>Buy</button>
        </div>
    </div>
  );
};

export default UserPurchaseBox;
