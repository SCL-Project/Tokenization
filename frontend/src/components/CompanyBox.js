import React, { useState, useEffect } from 'react';
import styles from '../styles/CompanyBox.module.css';
import WhatshotIcon from '@mui/icons-material/Whatshot';
import Web3 from 'web3';
import PauseIcon from '@mui/icons-material/Pause';
import PlayArrowIcon from '@mui/icons-material/PlayArrow';
import PriceChangeIcon from '@mui/icons-material/PriceChange';
import GetAppIcon from '@mui/icons-material/GetApp';
import AnnouncementIcon from '@mui/icons-material/Announcement';
import abi from '../contracts/abi.json';
import BurnMint from '../components/BurnMint';
import Offering from '../components/Offering';
import Pause from '../components/Pause';
import ChangePrice from '../components/ChangePrice';
import Withdraw from '../components/Withdraw';
import Announcement from '../components/Announcement';
import PayDividends from '../components/PayDividends';

const CompanyBox = () => {
  const [selectedOption, setSelectedOption] = useState('burnMint');  
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
        const contractAddress = '0x5b2Ad89fDba23B124590d303750F0EE82b84F3A5';
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

  const [anchorEl, setAnchorEl] = React.useState(null);
  const open = Boolean(anchorEl);
  const handleClick = (event) => {
    setAnchorEl(event.currentTarget);
  };
  const handleClose = () => {
    setAnchorEl(null);
  };

  return (
    <div>
        <div className={styles.rectangle}>
          <div className={styles.blackBox}>
            <button className={styles.button} onClick={() => setSelectedOption('burnMint')}><WhatshotIcon /> Burn/Mint</button>
            <button className={styles.button} onClick={() => setSelectedOption('pauseUnpause')}><PauseIcon /> Pause/Unpause</button>
            <button className={styles.button} onClick={() => setSelectedOption('startStopOffering')}><PlayArrowIcon/> Start/Stop Offering</button>
            <button className={styles.button} onClick={() => setSelectedOption('changePrice')}><PriceChangeIcon /> Change Price</button>
            <button className={styles.button} onClick={() => setSelectedOption('payDividends')}><PriceChangeIcon /> Dividends</button>
            <button className={styles.button} onClick={() => setSelectedOption('withdraw')}><GetAppIcon /> Withdraw</button>
            <button className={styles.button} onClick={() => setSelectedOption('announcement')}><AnnouncementIcon /> Announcement</button>
          </div>
          <div className={styles.contentArea}>
            {selectedOption === 'burnMint' && (<BurnMint web3={web3} account={account} contract={contract} />)}
            {selectedOption === 'pauseUnpause' && (<Pause web3={web3} account={account} contract={contract} />)}
            {selectedOption === 'startStopOffering' && (<Offering web3={web3} account={account} contract={contract} />)}
            {selectedOption === 'changePrice' && (<ChangePrice web3={web3} account={account} contract={contract} />)}
            {selectedOption === 'payDividends' && (<PayDividends web3={web3} account={account} contract={contract} />)}
            {selectedOption === 'withdraw' && (<Withdraw web3={web3} account={account} contract={contract} />)}
            {selectedOption === 'announcement' && (<Announcement web3={web3} account={account} contract={contract} />)}
          </div>
        </div>
    </div>
  );
};

export default CompanyBox;
