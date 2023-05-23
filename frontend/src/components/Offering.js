import React, { useState } from 'react';
import styles from '@/styles/CompanyBox.module.css';

const Offering = ({ web3, account, contract }) => {
    const [amount, setAmount] = useState(0);
    var [price, setPrice] = useState(0);


    const handleAmountChange = (e) => {
        setAmount(e.target.value);
    };

    const handlePriceChange = (e) => {
        setPrice(e.target.value);
    };

    const handleStart = async () => {
        if (amount <= 0 || price < 0) return;
        try {
            price = web3.utils.toWei(price, 'ether');
            await contract.methods.startOffering(price, amount).send({ from: account });
        } catch (err) {
            console.error(err);
        }
    };

    const handleStop = async () => {
        try {
            await contract.methods.stopOffering().send({ from: account });
        } catch (err) {
            console.error(err);
        }
    };

    return (
        <div>
            <h1>Start/Stop Offering</h1>
            <p>Amount</p>
            <input
                type="number"
                className={styles.amountBoxO}
                value={amount}
                onChange={handleAmountChange}
            />
            <p>Price</p>
            <input
                type="number"
                className={styles.priceBoxO}
                value={price}
                onChange={handlePriceChange}
            />
            <button className={styles.staOffering} onClick={handleStart}>
                Start Offering
            </button>
            <button className={styles.stoOffering} onClick={handleStop}>
                Stop Offering
            </button>
        </div>
    );
};

export default Offering;