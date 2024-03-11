import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import Web3 from 'web3';
import SmartContractABI from './ABIs/SmartContractABI.json';
import { Container, StyledButton, StyledTypography, BoldText, VideoBg  } from './TokentransferElements';
import Video from '../../videos/video.mp4';

const p2pLendingContractAddress = '0x71cd553Dd38566433653d070199b34D456761746';

const TokenTransfer = () => {
  const { borrowerAddress, amount } = useParams(); // Retrieve params from the URL
  const navigate = useNavigate();
  const [web3, setWeb3] = useState(null);
  const [userAccount, setUserAccount] = useState(null);
  const [p2pLendingContract, setP2PLendingContract] = useState(null);

  useEffect(() => {
    const initWeb3 = async () => {
      if (window.ethereum) {
        try {
          await window.ethereum.request({ method: 'eth_requestAccounts' });
          const web3Instance = new Web3(window.ethereum);
          setWeb3(web3Instance);

          const accounts = await web3Instance.eth.getAccounts();
          if (accounts.length > 0) {
            setUserAccount(accounts[0]);
          } else {
            console.log("No accounts found.");
          }

          const tempP2PLendingContract = new web3Instance.eth.Contract(SmartContractABI, p2pLendingContractAddress);
          setP2PLendingContract(tempP2PLendingContract);
        } catch (error) {
          console.error("Error connecting to MetaMask", error);
        }
      } else {
        console.log('Ethereum provider not found. Install MetaMask.');
      }
    };

    initWeb3();
  }, []);

  const grantCredit = async () => {
    if (!p2pLendingContract || !userAccount) {
      console.error("Contract not initialized or user account not found.");
      return;
    }

    const amountInWei = Web3.utils.toWei(amount, 'ether');

    try {
      console.log(`Granting credit of ${amount} tokens to ${borrowerAddress}...`);
      await p2pLendingContract.methods.transferFrom(userAccount, borrowerAddress, amountInWei).send({ from: userAccount });
      console.log("Credit granted successfully.");
      navigate('/');
    } catch (error) {
      console.error("Error granting credit:", error);
    }
  };

  return (
    <Container>
      <VideoBg autoPlay loop muted src={Video} type='video/mp4' />
      <StyledTypography>
        Are you sure you want to grant a Credit of <BoldText>{amount} USDC</BoldText> to <BoldText>{borrowerAddress}</BoldText>?
      </StyledTypography>
      <StyledButton onClick={grantCredit}>
        <BoldText>Grant Credit</BoldText>
      </StyledButton>
    </Container>

  );
};

export default TokenTransfer;