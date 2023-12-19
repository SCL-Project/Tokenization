// ***************************************************************************************************************
// SPDX-License-Identifier: MIT
// @title Oracle
// @authors Samuel Clauss & Dario Ganz
// Smart Contracts Lab, University of Zurich
// Created: December 15, 2023
// ***************************************************************************************************************
// Read the Whitepaper https://github.com/SCL-Project/Tokenization/blob/main/Whitepaper.md
// ***************************************************************************************************************
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ExchangeRate_EUR_CHF is Ownable {
    uint16 private exchangeRate = 950;

    /**
     * @dev Constructor to initialize the owner
     * @param initialOwner Address of the owner
     */
    constructor(address initialOwner) 
            Ownable(initialOwner)
        {}
    
    /*
     * @dev Function simulates an Oracle for the ExchangeRate between CHF and EUR. The rate given is EUR/CHF and 
     *      it is multiplied by factor 1000. The initial exchangeRate - 950 - represents the rate of 0.95.
     * @param _exchangeRate The ExchangeRate of EUR to CHF
     */
    function setExchangeRate(uint16 _exchangeRate) public onlyOwner {
        exchangeRate = _exchangeRate;
    }

    /*
     * @dev Function returns the ExchangeRate of this Oracle
     * @return uint16 Returns the ExchangeRate of EUR to CHF
    */
    function getExchangeRate() public view returns(uint16) {
        return exchangeRate;
    }
}