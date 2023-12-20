// ***************************************************************************************************************
// SPDX-License-Identifier: MIT
// @title Oracle
// @authors Samuel Clauss & Dario Ganz
// Smart Contracts Lab, University of Zurich
// Created: December 20, 2023
// ***************************************************************************************************************
// Read the Whitepaper https://github.com/SCL-Project/Tokenization/blob/main/Whitepaper.md
// ***************************************************************************************************************
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Oracle is Ownable {
    uint16 private exchangeRate = 950;

    /**
     * @dev Constructor to initialize the owner
     * @param initialOwner Address of the owner
     */
    constructor(address initialOwner) 
            Ownable(initialOwner)
        {}

    mapping (string => uint16) public VATRates;

    mapping (string => string) public currency;

    function setCurrency(string memory _country, string memory _currency) public onlyOwner {
        currency[_country] = _currency;
    }

    function deleteCurrency(string memory _country) public onlyOwner {
        delete currency[_country];
    }

    function getCurrency(string memory _country) public view returns(string memory) {
        return currency[_country];
    }

    /**
     * @dev The government (OnlyOwner) can devine a VAT-rate for each country (presumption of only 1 unified rate per country)
     * @param _country The country to set the VAT-rate for
     * @param VATRate The VAT-rate to be defined by the government according to the law
     */
    function setVatRate(string memory _country, uint16 VATRate) public onlyOwner {
        VATRates[_country] = VATRate;
    }

    /**
     * @dev The government (OnlyOwner) can delete wrong or outdated VAT-rates
     * @param _country The country to delete the VAT-rate for
     */
    function deleteVATRate(string memory _country) public onlyOwner {
        delete VATRates[_country];
    }

    /**
     * @dev Returns the demanded VATRate
     * @param _country The country whose VATRate is being returned
     */
    function getVATRate(string memory _country) public view returns(uint16) {
        return VATRates[_country];
    } 
    
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