import React, { useState } from 'react';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import styles from '../styles/CompanyBox.module.css';

const Offering = ({ web3, account, contract }) => {
    var [price, setPrice] = useState(0);

    const handleChange = (e) => {
        setPrice(e.target.value);
    };

    const handleSetPrice = async () => {
        if (price < 0) return;
        try {
            price = web3.utils.toWei(price, 'ether');
            await contract.methods.changePrice(price).send({ from: account });
        } catch (err) {
            console.error(err);
        }
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
                    <Button 
                        variant="contained"
                        onClick={handleSetPrice}
                        className={styles.button}
                        sx={{ 
                            width: '100%', 
                            mt: 1,
                        }}>
                            Change Price
                    </Button>
                </div>
        </div>
    );
};

export default Offering;