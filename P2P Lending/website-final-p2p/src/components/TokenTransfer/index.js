import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import Web3 from 'web3';
import SmartContractABI from './ABIs/SmartContractABI.json';
import { Container, StyledButton, StyledTypography, BoldText, VideoBg  } from './TokentransferElements';
import Video from '../../videos/video.mp4';

const p2pLendingContractAddress = '0x02f14672c41635213679107b6523dF5B098ba162';

const TokenTransfer = () => {
  const { borrowerAddress, amount, period } = useParams();
  console.log("Params:", { borrowerAddress, amount, period });
  const navigate = useNavigate();
  const [web3, setWeb3] = useState(null);
  const [userAccount, setUserAccount] = useState(null);
  const [p2pLendingContract, setP2PLendingContract] = useState(null);
  const [dueDate, setDueDate] = useState('');

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

  useEffect(() => {
    // Calculate the due date based on the period
    const calculateDueDate = () => {
      const today = new Date();
      const numberOfDaysToAdd = parseInt(period, 10);
      today.setDate(today.getDate() + numberOfDaysToAdd);

      // Format the date in a human-readable form, e.g., "March 26, 2024"
      const options = { year: 'numeric', month: 'long', day: 'numeric' };
      const dueDateString = today.toLocaleDateString('en-US', options);
      setDueDate(dueDateString);
    };

    calculateDueDate();
  }, [period]);

  const transferTokens = async () => {
    if (!p2pLendingContract || !userAccount) {
      console.error("Contract not initialized or user account not found.");
      return;
    }

    const amountInTokens = amount.toString();
    const amountInWei = (amountInTokens * Math.pow(10, 6)).toString(); // USDC has 6 decimals
    console.log(`Amount in Wei: ${amountInWei}`);

    const numberOfDaysToAdd = parseInt(period, 10);
    if (isNaN(numberOfDaysToAdd)) {
      console.error('Invalid period value:', period);
      return;
    }
    const dueDateTimestamp = Math.floor(Date.now() / 1000) + (period * 24 * 60 * 60);
    try {
      console.log(`Granting credit of ${amount} tokens to ${borrowerAddress}...`);
      await p2pLendingContract.methods.grantCredit(userAccount, borrowerAddress, amountInWei, dueDateTimestamp).send({ from: userAccount });
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
        Are you sure you want to grant a Credit of <BoldText>{amount} USDC</BoldText> to <BoldText>{borrowerAddress}</BoldText> with the due date on <BoldText>{dueDate}</BoldText>?
      </StyledTypography>
      <StyledButton onClick={transferTokens}>
        <BoldText>Grant Credit</BoldText>
      </StyledButton>
    </Container>

  );
};

export default TokenTransfer;