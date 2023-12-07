import React, { useState } from 'react';
import Box from '@mui/material/Box';
import TextField from '@mui/material/TextField';
import styles from '../styles/CompanyBox.module.css';
import LoadingButton from '@mui/lab/LoadingButton';


const BurnMint = ({ web3, account, contract }) => {
    var [amount, setAmount] = useState(0);
    const [loadingB, setLoadingB] = useState(false);
    const [loadingM, setLoadingM] = useState(false);


    const handleChange = (e) => {
        setAmount(e.target.value);
    };

    const handleBurn = async () => {
        setLoadingB(true);
        if (amount <= 0) return;
        try {
            amount = web3.utils.toWei(amount, 'ether');
            await contract.methods.burn(amount).send({ from: account });
            setAmount('');
        } catch (err) {
            console.error(err);
        }
        setLoadingB(false);
    };

    const handleMint = async () => {
        setLoadingM(true);
        if (amount <= 0) return;
        try {
            amount = web3.utils.toWei(amount, 'ether');
            await contract.methods.mint(account, amount).send({ from: account });
            setAmount('');
        } catch (err) {
            console.error(err);
        }
        setLoadingM(false);
    };

    return (
        <Box>
            <div className={styles.container}>
                <h1>Burn/Mint</h1>
                <TextField
                    id="filled-number"
                    label="Number"
                    type="number"
                    InputLabelProps={{
                        shrink: true,
                    }}
                    variant="filled"
                    value={amount}
                    onChange={handleChange}
                    className={styles.customTextField}
                />
                <div className={styles.flexButton}>
                    <LoadingButton
                        onClick={handleBurn}
                        loading={loadingB}
                        loadingPosition="end"
                        variant="contained"
                        sx={{ 
                            backgroundColor: 'white', 
                            color: 'black', 
                            '&:hover': { backgroundColor: 'grey', },
                            width: { xs: '100%', sm: 'calc(50% - 8px)' }, 
                            mt: 1, 
                            mr: { xs: 0, sm: 1 },                           
                        }}
                    >
                        <span>Burn</span>
                    </LoadingButton>
                    <LoadingButton
                        onClick={handleMint}
                        loading={loadingM}
                        loadingPosition="end"
                        variant="contained"
                        sx={{ backgroundColor: 'white', 
                            color: 'black', 
                            '&:hover': { backgroundColor: 'grey', }, 
                            width: { xs: '100%', sm: '50%' }, 
                            mt: 1 }}
                    >
                        <span>Mint</span>
                    </LoadingButton>
                </div>
            </div>
        </Box>
    );
};

export default BurnMint;