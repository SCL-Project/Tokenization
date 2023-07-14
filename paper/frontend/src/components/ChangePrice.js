import React, { useState } from 'react';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import styles from '../styles/CompanyBox.module.css';
import LoadingButton from '@mui/lab/LoadingButton';

const Offering = ({ web3, account, contract }) => {
    var [price, setPrice] = useState(0);
    const [loading, setLoading] = useState(false);

    const handleChange = (e) => {
        setPrice(e.target.value);
    };

    const handleSetPrice = async () => {
        setLoading(true);
        if (price < 0) return;
        try {
            price = web3.utils.toWei(price, 'ether');
            await contract.methods.changePrice(price).send({ from: account });
            setPrice('');
        } catch (err) {
            console.error(err);
        }
        setLoading(false);
    };
    return (
        <div className={styles.container}>
                <h1>Change Price</h1>
                <TextField
                    id="filled-number"
                    label="Price"
                    type="number"
                    InputLabelProps={{
                        shrink: true,
                    }}
                    variant="filled"
                    value={price}
                    onChange={handleChange}
                    className={styles.customTextField}
                />
                <div className={styles.flexButton}>
                    <LoadingButton 
                        variant="contained"
                        loadingPosition="end"
                        loading={loading}
                        onClick={handleSetPrice}
                        sx={{ 
                            backgroundColor: 'white', 
                            color: 'black', 
                            '&:hover': { backgroundColor: 'grey', },
                            width: '100%', 
                            mt: 1,
                        }}>
                            Change Price
                    </LoadingButton>
                </div>
        </div>
    );
};

export default Offering;