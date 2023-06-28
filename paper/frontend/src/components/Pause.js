import React, { useState } from 'react';
import styles from '../styles/CompanyBox.module.css';
import Button from '@mui/material/Button';


const Offering = ({ web3, account, contract }) => {
    const handlePause = async () => {
        try {
            await contract.methods.pause().send({ from: account });
        } catch (err) {
            console.error(err);
        }
    };

    const handleUnpause = async () => {
        try {
            await contract.methods.unpause().send({ from: account });
        } catch (err) {
            console.error(err);
        }
    };

    return (
        <div className={styles.container}>
            <h1>Pause/Unpause</h1>
            <div className={styles.flexButton}>
                    <Button 
                        variant="contained"
                        onClick={handlePause}
                        className={styles.button}
                        sx={{ 
                            width: { xs: '100%', sm: 'calc(50% - 8px)' }, 
                            mt: 1,
                            mr: { xs: 0, sm: 1 },                           
                        }}>
                            Pause
                    </Button>
                    <Button 
                        variant="contained"
                        onClick={handleUnpause}
                        className={styles.button}
                        sx={{ 
                            width: { xs: '100%', sm: '50%' }, 
                            mt: 1,                           
                        }}>
                            Unpause
                    </Button>
                </div>
        </div>
    );
};

export default Offering;