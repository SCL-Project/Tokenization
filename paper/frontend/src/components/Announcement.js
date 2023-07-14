import React, { useState } from 'react';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import styles from '../styles/CompanyBox.module.css';
import LoadingButton from '@mui/lab/LoadingButton';

const Offering = ({ web3, account, contract }) => {
    const [msg, setMsg] = useState('');
    const [loading, setLoading] = useState(false);
    
    const handleChange = (e) => {
        setMsg(e.target.value);
    };
    
    const handleAnnouncement = async () => {
        setLoading(true);
        try {
            await contract.methods.announcement(msg).send({ from: account });
        } catch (err) {
            console.error(err);
        }
        setLoading(false);
    };
    return (
        <div>
            <h1>Announcement</h1>
            <TextField
                id="outlined-multiline-static"
                label="Input your announcement"
                multiline
                rows={4}
                onChange={handleChange}
                className={styles.customTextField}
                sx={{ 
                    width: '100%', 
                }}
                />
            <div className={styles.flexButton}>
                <LoadingButton 
                    loading={loading}
                    loadingPosition="end"
                    variant="contained"
                    onClick={handleAnnouncement}
                    sx={{ 
                        backgroundColor: 'white', 
                        color: 'black', 
                        '&:hover': { backgroundColor: 'grey', },
                        width: '100%', 
                        mt: 1,
                    }}>
                        Send Announcement
                </LoadingButton>
            </div>
        </div>
    );
};

export default Offering;