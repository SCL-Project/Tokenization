import React, { useContext, useState, useEffect } from 'react';
import { H1, H3 } from './MarketplaceElements'; // Assuming H1 is correctly imported from your elements file
import { TextField, Box, Button, Paper, Typography, Grid } from '@mui/material';
import CloudUploadIcon from '@mui/icons-material/CloudUpload';
import Web3 from 'web3';
import SmartContractABI from './ABIs/SmartContractABI.json'
import StableCoinABI from './ABIs/StablecoinABI.json';
import { AuthContext } from "./../AuthContext";
import { Navigate } from "react-router-dom"; 

const p2pLendingContractAddress = '0x71cd553Dd38566433653d070199b34D456761746';
const stableCoinAddress = '0x9999f7fea5938fd3b1e26a12c3f2fb024e194f97';

const Marketplace = () => {
  const [lendingRequests, setLendingRequests] = useState([]);
  const { token, loading } = useContext(AuthContext);
    if (loading) {
      return null;
    }

    if (!token) {
      return <Navigate to="/login" replace />;
    }

  const addLendingRequest = (request) => {
    setLendingRequests([...lendingRequests, { ...request, period: `${request.period} days` }]); // Update to include "days"
  };

  return (
    <>
      <H1>Lenders Marketplace</H1>
      <LendingForm onNewRequest={addLendingRequest} />
      <LendingRequestsList requests={lendingRequests} />
    </>
  );
};

// Form for lenders to submit their lending request
const LendingForm = ({ onNewRequest }) => {
  const [amount, setAmount] = useState('');
  const [period, setPeriod] = useState('');
  const [walletAddress, setWalletAddress] = useState('');
  const [description, setDescription] = useState('');
  const [files, setFiles] = useState([]);
  const [p2pLendingContract, setP2PLendingContract] = useState(null);
  const [stableCoinContract, setStableCoinContract] = useState(null);

  useEffect(() => {
    async function initWeb3() {
      if (window.ethereum) {
        try {
          window.web3 = new Web3(window.ethereum);
          await window.ethereum.request({ method: 'eth_requestAccounts' });
          const web3 = window.web3;
          const p2pLendingContract = new web3.eth.Contract(SmartContractABI, p2pLendingContractAddress);
          const stableCoinContract = new web3.eth.Contract(StableCoinABI, stableCoinAddress);
          setP2PLendingContract(p2pLendingContract);
          setStableCoinContract(stableCoinContract);
        } catch (error) {
          console.error('Error initializing web3:', error);
        }
      } else {
        console.log('Non-Ethereum browser detected. Consider trying MetaMask!');
      }
    }
    initWeb3();
  }, []);

  const handleFileChange = (e) => {
    setFiles([...e.target.files]);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    onNewRequest({ amount, period, walletAddress, description, files });
    setAmount('');
    setPeriod('');
    setWalletAddress('');
    setDescription('');
    setFiles([]); // Reset files state to empty
  };

  return (
    <Box
      component="form"
      onSubmit={handleSubmit}
      sx={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center', // Centers items horizontally in the container
        '& > :not(style)': { m: 1, width: '50ch' }, // Applies margin and width to direct children
      }}
    >
      {/* Use TextField for amount input */}
      <TextField
        helperText="Please enter your desired amount"
        id="amount"
        label="Amount (in USD)"
        variant="outlined"
        type="number"
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
        required
      />
      {/* Use TextField for period input */}
      <TextField
        helperText="Please enter your desired period until the repayment"
        id="period"
        label="Period (in days)"
        variant="outlined"
        type="number"
        value={period}
        onChange={(e) => setPeriod(e.target.value)}
        required
      />
      {/* New TextField for wallet address */}
      <TextField
        helperText="Please enter your wallet address"
        id="walletAddress"
        label="Wallet Address"
        variant="outlined"
        type="text"
        value={walletAddress}
        onChange={(e) => setWalletAddress(e.target.value)}
        required
      />
      {/* Use TextField for period input */}
      <TextField
        helperText="Please enter a detailed description about the loan usage"
        id="description"
        label="Description of loan usage"
        variant="outlined"
        type="text"
        multiline // Allows multiple lines of text
        rows={5} // Adjusts the visible rows of the input field to 5 for more text
        value={description}
        onChange={(e) => setDescription(e.target.value)}
        required
      />
      <Button
        component="label"
        role={undefined}
        variant="outlined"
        tabIndex={-1}
        startIcon={<CloudUploadIcon />}
      >
        Upload Files
        <input
          type="file"
          multiple
          onChange={handleFileChange}
          style={{ display: 'none' }} // Hide the actual file input
        />
      </Button>
      {files.length > 0 && (
        <Box mt={2} sx={{ width: '50ch' }}> {/* Adjust width as needed */}
          <Typography variant="subtitle1">Selected files:</Typography>
          <ul>
            {files.map((file, index) => (
              <li key={index}>
                <Typography variant="body2">{file.name}</Typography>
              </li>
            ))}
          </ul>
        </Box>
      )}
      <Button type="submit" variant="contained">Add Request</Button>
    </Box>
  );
};

const approveAndGrantCredit = async (borrower, amount) => {
  try {
    const web3 = new Web3(window.ethereum);
    const p2pLendingContract = new web3.eth.Contract(SmartContractABI, p2pLendingContractAddress);
    const stableCoinContract = new web3.eth.Contract(StableCoinABI, stableCoinAddress);
    // Ensure MetaMask or any Ethereum provider is connected
    const accounts = await web3.eth.getAccounts();
    if (accounts.length === 0) {
      console.error("No accessible accounts. Ensure MetaMask is connected.");
      return;
    }

    const lender = accounts[0]; // Assuming the lender is the current user

    // Convert amount to the appropriate format based on the token's decimals
    const decimals = await stableCoinContract.methods.decimals().call(); // Fetching decimals dynamically
    const amountInWei = web3.utils.toBN(amount).mul(web3.utils.toBN(10).pow(web3.utils.toBN(decimals)));
    
    // Approve the P2P Lending Contract to spend the tokens on behalf of the lender
    await stableCoinContract.methods.approve(p2pLendingContractAddress, amountInWei.toString()).send({ from: lender })
      .on('transactionHash', hash => {
        console.log(`Approval transaction hash: ${hash}`);
      });
    // After approval, grant credit using the P2P Lending Contract
    await p2pLendingContract.methods.grantCredit(borrower, amountInWei.toString()).send({ from: lender })
      .on('transactionHash', function(hash){
        console.log(`Transaction hash: ${hash}`);
      })
      .on('receipt', function(receipt){
        console.log('Credit granted successfully', receipt);
      })
      .on('error', function(error, receipt) {
        console.error('Error granting credit:', error);
        if (receipt) console.error('Transaction receipt:', receipt);
      });

  } catch (error) {
    console.error('Error in approving and granting credit:', error);
  }
};

// Component to display all lending requests
const LendingRequestsList = ({ requests }) => {

  if (requests.length === 0) {
    return (
      <Box display="flex" justifyContent="center" mt={2}>
        <H3>No Loan Requests yet</H3>
      </Box>
    );
  }

  return (
    <Box display="flex" flexDirection="column" alignItems="center" mt={2}>
      <H3>Current Lending Requests</H3>
      {requests.map((request, index) => (
        <Paper key={index} elevation={3} style={{ margin: '16px 0', padding: '16px', width: '80%' }}>
          <Grid container spacing={2}>
            <Grid item xs={12} sm={4}>
              <Typography variant="body1"><strong>Amount:</strong> ${request.amount}</Typography>
            </Grid>
            <Grid item xs={12} sm={4}>
              <Typography variant="body1"><strong>Period:</strong> {request.period}</Typography>
            </Grid>
            <Grid item xs={12} sm={4}>
              <Typography variant="body1"><strong>Description:</strong> {request.description}</Typography>
            </Grid>
            {request.files && request.files.length > 0 && (
              <Grid item xs={12}>
                <Typography variant="body1"><strong>Files:</strong></Typography>
                <ul>
                  {request.files.map((file, fileIndex) => (
                    <li key={fileIndex}>{file.name}</li>
                  ))}
                </ul>
              </Grid>
            )}
            {/* Grant Credit Button */}
            <Grid item xs={12}>
              <Button
                variant="contained"
                color="primary"
                onClick={() => approveAndGrantCredit(request.borrowerAddress, request.amount)}
              >
                Grant Credit
              </Button>
            </Grid>
          </Grid>
        </Paper>
      ))}
    </Box>
  );
};

export default Marketplace;
