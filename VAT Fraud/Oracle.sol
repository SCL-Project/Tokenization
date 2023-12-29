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
     * @dev Constructor to initialize the owner. Owner of the oracle is a trusted third party
     * @param initialOwner Address of the owner
     */
    constructor(address initialOwner) 
            Ownable(initialOwner)
        {}
    //------------------------------------------------Mappings----------------------------------------------------

    /**
     * @dev Stores the VAT rates for different indexed countries
     */
    mapping (string => uint16) private VATRates;

    /**
     * @dev Stores the currency for different indexed countries
     */
    mapping (string => string) private currency;

    //-----------------------------------------------Functions----------------------------------------------------

    /**
     * @dev Sets the currency for a specific country. Can only be called by the contract owner (OnlyOwner)
     * @param _country The country to set the currency for
     * @param _currency The currency to be set for the specific country
     */
    function setCurrency(string memory _country, string memory _currency) external onlyOwner {
        currency[_country] = _currency;
    }

    /**
     * @dev Deletes the currency for a specific country. Can only be called by the contract owner
     * @param _country The country whose currency gets deleted
     */
    function deleteCurrency(string memory _country) external onlyOwner {
        delete currency[_country];
    }

    /**
     * @dev Retrieves the currency for a specific country
     * @param _country The country to get the currency for
     * @return string Retunrs the currency of the specified country
     */
    function getCurrency(string memory _country) external view returns(string memory) {
        return currency[_country];
    }

    /**
     * @dev The contract owner (OnlyOwner) can devine a VAT rate for each country 
     *      (presumption of only 1 unified rate per country)
     * @param _country The country to set the VAT rate for
     * @param VATRate The VAT rate to be defined by the government according to the law
     */
    function setVatRate(string memory _country, uint16 VATRate) external onlyOwner {
        VATRates[_country] = VATRate;
    }

    /**
     * @dev The contract owner can delete wrong or outdated VAT rates
     * @param _country The country to delete the VAT rate for
     */
    function deleteVATRate(string memory _country) external onlyOwner {
        delete VATRates[_country];
    }

    /**
     * @dev Returns the demanded VATRate
     * @param _country The country whose VATRate is being returned
     * @return uint16 Returns the VAT rate of the specified country
     */
    function getVATRate(string memory _country) external view returns(uint16) {
        return VATRates[_country];
    } 
    
    /**
     * @dev Function simulates an Oracle for the ExchangeRate between CHF and EUR. The rate given is EUR/CHF
     *      and it is multiplied by factor 1000. The initial exchangeRate - 950 - represents the rate of 0.95
     * @param _exchangeRate The ExchangeRate of EUR to CHF
     */
    function setExchangeRate(uint16 _exchangeRate) external onlyOwner {
        exchangeRate = _exchangeRate;
    }

    /**
     * @dev Function returns the ExchangeRate of this Oracle
     * @return uint16 Returns the ExchangeRate of EUR to CHF
    */
    function getExchangeRate() external view returns(uint16) {
        return exchangeRate;
    }
}