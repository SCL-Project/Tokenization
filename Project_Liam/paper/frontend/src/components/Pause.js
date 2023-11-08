import React, { useState } from 'react';
import styles from '../styles/CompanyBox.module.css';
import Button from '@mui/material/Button';
import LoadingButton from '@mui/lab/LoadingButton';
import { set } from 'firebase/database';

const Offering = ({ web3, account, contract }) => {
    const [loadingP, setLoadingP] = useState(false);
    const [loadingU, setLoadingU] = useState(false);

    const handlePause = async () => {
        setLoadingP(true);
        try {
            await contract.methods.pause().send({ from: account });
        } catch (err) {
            console.error(err);
        }
        setLoadingP(false);
    };

    const handleUnpause = async () => {
        setLoadingU(true);
        try {
            await contract.methods.unpause().send({ from: account });
        } catch (err) {
            console.error(err);
        }
        setLoadingU(false);
    };

    return (
        <div className={styles.container}>
            <h1>Pause/Unpause</h1>
            <div className={styles.flexButton}>
                    <LoadingButton 
                        variant="contained"
                        loadingPosition="end"
                        loading={loadingP}
                        onClick={handlePause}
                        sx={{ 
                            backgroundColor: 'white', 
                            color: 'black', 
                            '&:hover': { backgroundColor: 'grey', },
                            width: { xs: '100%', sm: 'calc(50% - 8px)' }, 
                            mt: 1,
                            mr: { xs: 0, sm: 1 },                           
                        }}>
                            Pause
                    </ LoadingButton>
                    <LoadingButton 
                        variant="contained"
                        loadingPosition="end"
                        loading={loadingU}
                        onClick={handleUnpause}
                        sx={{ 
                            backgroundColor: 'white', 
                            color: 'black', 
                            '&:hover': { backgroundColor: 'grey', },
                            width: { xs: '100%', sm: '50%' }, 
                            mt: 1,                           
                        }}>
                            Unpause
                    </LoadingButton>
                </div>
        </div>
    );
};

export default Offering;