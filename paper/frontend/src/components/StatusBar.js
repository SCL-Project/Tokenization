import React, { useState, useEffect } from 'react';
import useWeb3 from '../hooks/useWeb3';  // adjust the path as necessary

const StatusBar = () => {
    const { web3, account, contract } = useWeb3();
    const [contractPaused, setContractPaused] = useState(false);
    const [tokenPrice, setTokenPrice] = useState(0);
    const [currentOffer, setCurrentOffer] = useState(0);
    const [priceError, setPriceError] = useState(null);
    const [offerError, setOfferError] = useState(null);


    const fetchTokenPrice = async () => {
        try {
            if (contract) {
                const price = await contract.methods.offeringPrice().call();
                const priceInMatic = web3.utils.fromWei(price.toString(), 'ether');
                setTokenPrice(parseFloat(priceInMatic));
            }
        } catch (err) {
            setPriceError('Error fetching token price. Please try again later.');
            console.log(priceError);
            console.log(err);
        }
    }; 

    const fetchCurrentOffer = async () => {
        try {
            if (contract) {
                const offer = await contract.methods.offeringAmount().call();
                const offerInTokens = web3.utils.fromWei(offer.toString(), 'ether');
                setCurrentOffer(parseFloat(offerInTokens));
            }
        } catch (err) {
            setOfferError('Error fetching current offer. Please try again later.');
            console.log(offerError);
            console.log(err);
        }
    };

    useEffect(() => {
        fetchTokenPrice();
        fetchCurrentOffer();
    }, [contract]);

    return (
        <div style={{
            position: 'fixed',
            bottom: 0,
            left: 0,
            width: '100%',
            backgroundColor: '#333',
            color: '#fff',
            display: 'flex',
            justifyContent: 'space-around',
        }}>
                    <p>{`Current Price: ${tokenPrice}`}</p>
                    <p>{`Available shares for purchase: ${currentOffer}`}</p>
                    <p>{`Current Contract Address: ${contract ? contract.options.address : 'Contract not loaded'}`}</p>
        </div>
    );
};

export default StatusBar;
