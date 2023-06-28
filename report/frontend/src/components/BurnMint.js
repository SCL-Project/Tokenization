import React, { useState } from 'react';
import Box from '@mui/material/Box';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import styles from '../styles/CompanyBox.module.css';

const BurnMint = ({ web3, account, contract }) => {
    const [amount, setAmount] = useState(0);

    const handleChange = (e) => {
        setAmount(e.target.value);
    };

    const handleBurn = async () => {
        if (amount <= 0) return;
        try {
            await contract.methods.burn(amount).send({ from: account });
        } catch (err) {
            console.error(err);
        }
    };

    const handleMint = async () => {
        if (amount <= 0) return;
        try {
            await contract.methods.mint(account, amount).send({ from: account });
        } catch (err) {
            console.error(err);
        }
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
                    <Button 
                        variant="contained"
                        onClick={handleBurn}
                        className={styles.button}
                        sx={{ 
                            width: { xs: '100%', sm: 'calc(50% - 8px)' }, 
                            mt: 1,
                            mr: { xs: 0, sm: 1 },                           
                        }}>
                            Burn
                    </Button>
                    <Button 
                        variant="contained"
                        onClick={handleMint}
                        className={styles.button}
                        sx={{                            
                            width: { xs: '100%', sm: '50%' }, 
                            mt: 1,                           
                        }}>
                            Mint
                    </Button>
                </div>
            </div>
        </Box>
    );
};

export default BurnMint;