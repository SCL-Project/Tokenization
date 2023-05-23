import React, { useState } from 'react';
import styles from '@/styles/CompanyBox.module.css';

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
        <div>
            <h1>Pause/Unpause</h1>
            <button className={styles.pause} onClick={handlePause}>
                Pause
            </button>
            <button className={styles.unpause} onClick={handleUnpause}>
                Unpause
            </button>
        </div>
    );
};

export default Offering;