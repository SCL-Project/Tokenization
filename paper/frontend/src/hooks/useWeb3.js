import { useState, useEffect } from 'react';
import { useEthereumAddress } from '../contexts/EthereumAddressContext';
import Web3 from 'web3';
import abi from '../contracts/abi.json';

const useWeb3 = () => {
  const [web3, setWeb3] = useState(null);
  const [account, setAccount] = useState(null);
  const [contract, setContract] = useState(null);
  const { setEthereumAddress } = useEthereumAddress();

  useEffect(() => {
    if (typeof window !== 'undefined' && window.ethereum) {
      const loadWeb3AndBlockchainData = async () => {
        window.web3 = new Web3(window.ethereum);
        await window.ethereum.enable();
        const web3 = window.web3;
        setWeb3(web3);

        // Load the current user's account
        const accounts = await web3.eth.getAccounts();
        setAccount(accounts[0]);
        setEthereumAddress(accounts[0]);

        // Load the smart contract
        const contractAddress = '0x5b2Ad89fDba23B124590d303750F0EE82b84F3A5';
        const contract = new web3.eth.Contract(abi, contractAddress);
        setContract(contract);
      };
      loadWeb3AndBlockchainData();
    } else {
      console.log('Please install MetaMask!');
    }
  }, []);

  return { web3, account, contract };
};

export default useWeb3;
