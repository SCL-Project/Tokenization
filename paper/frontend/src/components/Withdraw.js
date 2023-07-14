import React, { useState } from 'react';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import styles from '../styles/CompanyBox.module.css';
import LoadingButton from '@mui/lab/LoadingButton';

const Offering = ({ web3, account, contract }) => {
    const [loading, setLoading] = useState(false);

    const handleWithdraw = async () => {
        setLoading(true);
        try {
            await contract.methods.withdraw().send({ from: account });
        } catch (err) {
            console.error(err);
        }
        setLoading(false);
    };
    return (
        <div className={styles.container}>
                <h1>Withdraw</h1>
                <div className={styles.flexButton}>
                    <LoadingButton 
                        loading={loading}
                        loadingPosition="end"
                        variant="contained"
                        onClick={handleWithdraw}
                        sx={{
                            backgroundColor: 'white', 
                            color: 'black', 
                            '&:hover': { backgroundColor: 'grey', }, 
                            width: '100%', 
                            mt: 1,
                        }}>
                            Withdraw
                    </LoadingButton>
                </div>
        </div>
    );
};

export default Offering;