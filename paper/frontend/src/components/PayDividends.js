import React, { useState } from 'react';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import styles from '../styles/CompanyBox.module.css';
import LoadingButton from '@mui/lab/LoadingButton';

const PayDividends = ({ web3, account, contract }) => {
    let [amount, setAmount] = useState(0);
    const [loading, setLoading] = useState(false);

    const handleChange = (e) => {
        setAmount(e.target.value);
    };

    const handleSetAmount = async () => {
        setLoading(true);
        if (amount < 0) return;
        try {
            amount = web3.utils.toWei(amount, 'ether');
            await contract.methods.payDividends().send({ from: account, value: amount });
            setAmount('');
        } catch (err) {
            console.error(err);
        }
        setLoading(false);
    };
    
    return (
        <div className={styles.container}>
                <h1>Pay Dividends</h1>
                <TextField
                    id="filled-number"
                    label="Amount"
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
                        variant="contained"
                        loading={loading}
                        loadingPosition="end"
                        onClick={handleSetAmount}
                        sx={{ 
                            backgroundColor: 'white', 
                            color: 'black', 
                            '&:hover': { backgroundColor: 'grey', },
                            width: '100%', 
                            mt: 1,
                        }}>
                            Pay out dividends
                    </LoadingButton>
                </div>
        </div>
    );
};

export default PayDividends;