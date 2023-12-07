import React, { useState } from 'react';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import styles from '../styles/CompanyBox.module.css';
import LoadingButton from '@mui/lab/LoadingButton';

const Offering = ({ web3, account, contract }) => {
    let [amount, setAmount] = useState(0);
    let [price, setPrice] = useState(0);
    const [loadingStart, setLoadingStart] = useState(false);
    const [loadingStop, setLoadingStop] = useState(false);



    const handleAmountChange = (e) => {
        setAmount(e.target.value);
    };

    const handlePriceChange = (e) => {
        setPrice(e.target.value);
    };

    const handleStart = async () => {
        setLoadingStart(true);
        if (amount <= 0 || price < 0) return;
        try {
            price = web3.utils.toWei(price, 'ether');
            amount = web3.utils.toWei(amount, 'ether');
            await contract.methods.startOffering(price, amount).send({ from: account });
            setAmount('');
            setPrice('');
        } catch (err) {
            console.error(err);
        }
        setLoadingStart(false);
    };

    const handleStop = async () => {
        setLoadingStop(true);
        try {
            await contract.methods.stopOffering().send({ from: account });
        } catch (err) {
            console.error(err);
        }
        setLoadingStop(false);
    };

    return (
        <div className={styles.container}>
            <h1>Offering</h1>
            <TextField
                id="filled-number"
                label="Amount"
                type="number"
                InputLabelProps={{
                    shrink: true,
                }}
                variant="filled"
                value={amount}
                onChange={handleAmountChange}
                className={styles.customTextField}
            />
            <TextField
                id="filled-number"
                label="Price"
                type="number"
                InputLabelProps={{
                    shrink: true,
                }}
                sx={{
                    mt: 1,
                }}
                variant="filled"
                value={price}
                onChange={handlePriceChange}
                className={styles.customTextField}
            />
            <div className={styles.flexButton}>
                <LoadingButton 
                    variant="contained"
                    loadingPosition="end"
                    loading={loadingStart}
                    onClick={handleStart}
                    sx={{ 
                        backgroundColor: 'white', 
                        color: 'black', 
                        '&:hover': { backgroundColor: 'grey', },
                        width: { xs: '100%', sm: 'calc(50% - 8px)' }, 
                        mt: 1,
                        mr: { xs: 0, sm: 1 },                           
                    }}>
                        Start Offering
                </LoadingButton>
                <LoadingButton 
                    variant="contained"
                    loadingPosition="end"
                    loading={loadingStop}
                    onClick={handleStop}
                    sx={{    
                        backgroundColor: 'white', 
                        color: 'black', 
                        '&:hover': { backgroundColor: 'grey', },                        
                        width: { xs: '100%', sm: '50%' }, 
                        mt: 1,                           
                    }}>
                        Stop Offering
                </LoadingButton>
            </div>
        </div>
        
    );
};

export default Offering;