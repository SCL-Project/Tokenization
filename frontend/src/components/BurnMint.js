import React, { useState } from 'react';
import styles from '@/styles/CompanyBox.module.css';

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
        <div>
            <h1>Burn/Mint</h1>
            <input
                type="number"
                className={styles.amountBox}
                value={amount}
                onChange={handleChange}
            />
            <button className={styles.burn} onClick={handleBurn}>
                Burn
            </button>
            <button className={styles.mint} onClick={handleMint}>
                Mint
            </button>
        </div>
    );
};

export default BurnMint;