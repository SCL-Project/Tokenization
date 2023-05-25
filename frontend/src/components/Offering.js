import React, { useState } from 'react';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import styles from '../styles/CompanyBox.module.css';

const Offering = ({ web3, account, contract }) => {
    const [amount, setAmount] = useState(0);
    var [price, setPrice] = useState(0);


    const handleAmountChange = (e) => {
        setAmount(e.target.value);
    };

    const handlePriceChange = (e) => {
        setPrice(e.target.value);
    };

    const handleStart = async () => {
        if (amount <= 0 || price < 0) return;
        try {
            price = web3.utils.toWei(price, 'ether');
            await contract.methods.startOffering(price, amount).send({ from: account });
        } catch (err) {
            console.error(err);
        }
    };

    const handleStop = async () => {
        try {
            await contract.methods.stopOffering().send({ from: account });
        } catch (err) {
            console.error(err);
        }
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
                <Button 
                    variant="contained"
                    onClick={handleStart}
                    className={styles.button}
                    sx={{ 
                        width: { xs: '100%', sm: 'calc(50% - 8px)' }, 
                        mt: 1,
                        mr: { xs: 0, sm: 1 },                           
                    }}>
                        Start Offering
                </Button>
                <Button 
                    variant="contained"
                    onClick={handleStop}
                    className={styles.button}
                    sx={{                            
                        width: { xs: '100%', sm: '50%' }, 
                        mt: 1,                           
                    }}>
                        Stop Offering
                </Button>
            </div>
        </div>
        
    );
};

export default Offering;