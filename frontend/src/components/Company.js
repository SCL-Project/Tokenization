import React, { useState } from 'react';
import styles from '../styles/CompanyBox.module.css';
import ResponsiveDrawer from './ResponsiveDrawer';

const Company = () => {
    return (
        <div className={styles.container1}>  
            <ResponsiveDrawer />
        </div>
    );
};

export default Company;