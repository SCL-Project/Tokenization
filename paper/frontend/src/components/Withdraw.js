import React, { useState } from 'react';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import styles from '../styles/CompanyBox.module.css';

const Offering = ({ web3, account, contract }) => {
    const handleWithdraw = async () => {
        try {
            await contract.methods.withdraw().send({ from: account });
        } catch (err) {
            console.error(err);
        }
    };
    return (
        <div className={styles.container}>
                <h1>Withdraw</h1>
                <div className={styles.flexButton}>
                    <Button 
                        variant="contained"
                        onClick={handleWithdraw}
                        className={styles.button}
                        sx={{ 
                            width: '100%', 
                            mt: 1,
                        }}>
                            Withdraw
                    </Button>
                </div>
        </div>
    );
};

export default Offering;