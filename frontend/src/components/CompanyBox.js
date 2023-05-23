import React, { useState, useEffect } from 'react';
import styles from '@/styles/CompanyBox.module.css';
import Web3 from 'web3';
import abi from '../contracts/abi.json';
import BurnMint from '../components/BurnMint';
import Offering from '../components/Offering';
import Pause from '../components/Pause';




const CompanyBox = () => {
  const [selectedOption, setSelectedOption] = useState(null);  
  const [web3, setWeb3] = useState(null);
  const [account, setAccount] = useState(null);
  const [contract, setContract] = useState(null);

  useEffect(() => {
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

    loadWeb3AndBlockchainData();
  }, []);

  const handleMenuClick = (option) => {
    setSelectedOption(option);
  };

  return (
    <div>
        <div className={styles.rectangle}>
          <div className={styles.blackBox}>
            <button className={styles.button} onClick={() => setSelectedOption('burnMint')}>Burn/Mint</button>
            <button className={styles.button} onClick={() => setSelectedOption('pauseUnpause')}>Pause/Unpause</button>
            <button className={styles.button} onClick={() => setSelectedOption('startStopOffering')}>Start/Stop Offering</button>
            <button className={styles.button} onClick={() => setSelectedOption('changePrice')}>Change Price</button>
            <button className={styles.button} onClick={() => setSelectedOption('withdraw')}>Withdraw</button>
            <button className={styles.button} onClick={() => setSelectedOption('announcement')}>Announcement</button>
          </div>
          <div className={styles.contentArea}>
            {selectedOption === 'burnMint' && (<BurnMint web3={web3} account={account} contract={contract} />)}
            {selectedOption === 'pauseUnpause' && (<Pause web3={web3} account={account} contract={contract} />)}
            {selectedOption === 'startStopOffering' && (<Offering web3={web3} account={account} contract={contract} />)}
            {/* {selectedOption === 'pauseUnpause' && <PauseUnpauseComponent />}
            {selectedOption === 'startStopOffering' && <StartStopOfferingComponent />} */}
          </div>
        </div>
    </div>
  );
};

export default CompanyBox;
