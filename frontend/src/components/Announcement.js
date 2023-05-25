import React, { useState } from 'react';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import styles from '../styles/CompanyBox.module.css';

const Offering = ({ web3, account, contract }) => {
    const [msg, setMsg] = useState("Enter your announcement here");

    
    const handleChange = (e) => {
        setMsg(e.target.value);
    };
    
    const handleAnnouncement = async () => {
        try {
            await contract.methods.announcement(msg).send({ from: account });
        } catch (err) {
            console.error(err);
        }
    };
    return (
        <div>
            <h1>Announcement</h1>
            <TextField
                id="outlined-multiline-static"
                label="Input your announcement"
                multiline
                rows={4}
                defaultValue=""
                className={styles.customTextField}
                sx={{ 
                    width: '100%', 
                }}
                />
            <div className={styles.flexButton}>
                <Button 
                    variant="contained"
                    onClick={handleAnnouncement}
                    className={styles.button}
                    sx={{ 
                        width: '100%', 
                        mt: 1,
                    }}>
                        Send Announcement
                </Button>
            </div>
        </div>
    );
};

export default Offering;