import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom'; 
import { H1, H3, Files, FileTitle } from './MarketplaceElements';
import { TextField, Box, Button, Paper, Typography, Grid } from '@mui/material';
import CloudUploadIcon from '@mui/icons-material/CloudUpload';
import Web3 from 'web3';
import SmartContractABI from './ABIs/SmartContractABI.json'
import StableCoinABI from './ABIs/StablecoinABI.json'

const p2pLendingContractAddress = '0x02f14672c41635213679107b6523dF5B098ba162';
const stableCoinAddress = '0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238';


const Marketplace = () => {
  const [lendingRequests, setLendingRequests] = useState([]);
  const [stableCoinContract, setStableCoinContract] = useState(null);
  const [p2pLendingContract, setP2PLendingContract] = useState(null);
  const [userAccount, setUserAccount] = useState(null);
  const addLendingRequest = (request) => {
    console.log("Received in addLendingRequest:", request);
    setLendingRequests([...lendingRequests, { ...request, period: `${request.period}` }]);
  };

  const navigate = useNavigate();

  useEffect(() => {
    const initWeb3 = async () => {
      if (window.ethereum) {
        try {
          // Request account access
          await window.ethereum.request({ method: 'eth_requestAccounts' });
          const web3 = new Web3(window.ethereum);
          
          // Fetch the list of accounts
          const accounts = await web3.eth.getAccounts();
          if (accounts.length > 0) {
            setUserAccount(accounts[0]); // Sets the first account as the user account
          } else {
            console.log("No accounts found.");
          }
          
          // Initialize contract instances
          const tempStableCoinContract = new web3.eth.Contract(
            StableCoinABI,
            stableCoinAddress
          );
          
          const tempP2PLendingContract = new web3.eth.Contract(
            SmartContractABI,
            p2pLendingContractAddress
          );
          
          setStableCoinContract(tempStableCoinContract);
          setP2PLendingContract(tempP2PLendingContract);
        } catch (error) {
          console.error("Error connecting to MetaMask", error);
        }
      } else {
        console.log('Ethereum provider not found. Install MetaMask.');
      }
    };
    
    initWeb3().catch(console.error);
  }, []);
  
  const approveCredit = async (borrowerAddress, amount, period) => {
    if (!stableCoinContract || !userAccount) {
      console.log("In approveCredit - Period:", period); 
      return;
    }
    
    const amountInTokens = amount.toString();
    const amountInWei = (amountInTokens * Math.pow(10, 6)).toString(); // For a token with 6 decimals
    console.log(amountInWei);

    try {
      console.log(`Attempting to approve ${amount} tokens for the P2P lending contract...`);
      await stableCoinContract.methods.approve(p2pLendingContractAddress, amountInWei).send({ from: userAccount });

      console.log("Approval successful.");
    } catch (error) {
      console.error("Approval error:", error);
    }
    // Navigate only after successful approval
    console.log(`Navigating with borrowerAddress: ${borrowerAddress}, amount: ${amount}, period: ${period}`);
    navigate(`/Marketplace/grant-credit/${borrowerAddress}/${amount}/${period}`);
  };
  

  return (
    <>
      <H1>Lenders Marketplace</H1>
      <LendingForm onNewRequest={addLendingRequest} />
      <LendingRequestsList requests={lendingRequests} onApproveCredit={approveCredit}/>
    </>
  );
};

// Form for lenders to submit their lending request
const LendingForm = ({ onNewRequest }) => {
  const [amount, setAmount] = useState('');
  const [period, setPeriod] = useState('');
  const [borrowerAddress, setWalletAddress] = useState('');
  const [description, setDescription] = useState('');
  const [files, setFiles] = useState([]);

  const handleFileChange = (e) => {
    setFiles([...e.target.files]);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log("Submitting request with period:", period);
    onNewRequest({ amount, period, borrowerAddress, description, files });
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
        sx={{
          '& label.Mui-focused': {
            color: 'grey', // Color of the label when the TextField is focused
          },
          '& .MuiInput-underline:after': {
            borderBottomColor: '#7393B3', // Color of the underline when the TextField is focused
          },
          '& .MuiOutlinedInput-root': {
            '&:hover fieldset': {
              borderColor: '#7393B3', // Color of the border when hovered
            },
            '&.Mui-focused fieldset': {
              borderColor: '#7393B3', // Color of the border when the TextField is focused
            },
          },
        }}
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
        sx={{
          '& label.Mui-focused': {
            color: 'grey', // Color of the label when the TextField is focused
          },
          '& .MuiInput-underline:after': {
            borderBottomColor: '#7393B3', // Color of the underline when the TextField is focused
          },
          '& .MuiOutlinedInput-root': {
            '&:hover fieldset': {
              borderColor: '#7393B3', // Color of the border when hovered
            },
            '&.Mui-focused fieldset': {
              borderColor: '#7393B3', // Color of the border when the TextField is focused
            },
          },
        }}
      />
      {/* New TextField for wallet address */}
      <TextField
        helperText="Please enter your wallet address"
        id="walletAddress"
        label="Wallet Address"
        variant="outlined"
        type="text"
        value={borrowerAddress}
        onChange={(e) => setWalletAddress(e.target.value)}
        required
        sx={{
          '& label.Mui-focused': {
            color: 'grey', // Color of the label when the TextField is focused
          },
          '& .MuiInput-underline:after': {
            borderBottomColor: '#7393B3', // Color of the underline when the TextField is focused
          },
          '& .MuiOutlinedInput-root': {
            '&:hover fieldset': {
              borderColor: '#7393B3', // Color of the border when hovered
            },
            '&.Mui-focused fieldset': {
              borderColor: '#7393B3', // Color of the border when the TextField is focused
            },
          },
        }}
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
        sx={{
          '& label.Mui-focused': {
            color: 'grey', // Color of the label when the TextField is focused
          },
          '& .MuiInput-underline:after': {
            borderBottomColor: '#7393B3', // Color of the underline when the TextField is focused
          },
          '& .MuiOutlinedInput-root': {
            '&:hover fieldset': {
              borderColor: '#7393B3', // Color of the border when hovered
            },
            '&.Mui-focused fieldset': {
              borderColor: '#7393B3', // Color of the border when the TextField is focused
            },
          },
        }}
      />
      <Button
        component="label"
        role={undefined}
        variant="contained"
        tabIndex={-1}
        startIcon={<CloudUploadIcon />}
        sx={{
          backgroundColor: '#7393B3', // Button background color
          color: '#ffffff', // Text color
          '&:hover': {
            backgroundColor: '#405469', // Darker background color on hover
            fontWeight: 'bold',
          },
        }}
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
          <FileTitle variant="subtitle1">Selected files:</FileTitle>
          <ul>
            {files.map((file, index) => (
              <li key={index}>
                <Files variant="body2">{file.name}</Files>
              </li>
            ))}
          </ul>
        </Box>
      )}
      <Button
        type="submit"
        variant="contained"
        sx={{
          backgroundColor: '#7393B3', // Button background color
          color: '#ffffff', // Text color
          '&:hover': {
            backgroundColor: '#405469', // Darker background color on hover
            fontWeight: 'bold',
          },
        }}
      >
      Add Request
      </Button>
    </Box>
  );
};

// Component to display all lending requests
const LendingRequestsList = ({ requests, onApproveCredit }) => {
  
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
        <Paper key={index} elevation={3} style={{ margin: '16px 0', padding: '16px', width: '95%', backgroundColor: '#F5F5F5' }}>
          <Grid container spacing={2}>
            <Grid item xs={12} sm={4}>
              <Typography variant="body1"><strong>Amount:</strong> ${request.amount}</Typography>
            </Grid>
            <Grid item xs={12} sm={4}>
              <Typography variant="body1"><strong>Period:</strong> {request.period} days</Typography>
            </Grid>
            <Grid item xs={12} sm={4}>
              <Typography variant="body1"><strong>Description:</strong> {request.description}</Typography>
            </Grid>
            {request.files && request.files.length > 0 && (
              <Grid item xs={12}>
                <Typography variant="body1"><strong>Files:</strong></Typography>
                <Files>
                  {request.files.map((file, fileIndex) => (
                    <li key={fileIndex}>{file.name}</li>
                  ))}
                </Files>
              </Grid>
            )}
            {/* Grant Credit Button */}
            <Grid item xs={12}>
              <Button
                variant="contained"
                color="primary"
                onClick={() => onApproveCredit(request.borrowerAddress, request.amount, request.period)}
                sx={{
                  backgroundColor: '#7393B3', // Button background color
                  color: '#ffffff', // Text color
                  '&:hover': {
                    backgroundColor: '#405469', // Darker background color on hover
                    fontWeight: 'bold',
                  },
                }}
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