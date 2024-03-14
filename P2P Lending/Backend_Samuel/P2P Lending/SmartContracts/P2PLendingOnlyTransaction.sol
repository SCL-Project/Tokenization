// ***************************************************************************************************************
// SPDX-License-Identifier: MIT
/// @title P2PLending Contract
/// @author Dario Ganz
// Smart Contracts Lab, University of Zurich
// Created: February 26, 2024
// ***************************************************************************************************************
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract P2PLending {
    address public stablecoinAddress; // Address of the stablecoin contract

    // Event to emit when a credit is granted successfully
    event CreditGranted(address indexed lender, address indexed borrower, uint256 amount);

    /**
     * @dev Sets the stablecoin contract address.
     * @param _stablecoinAddress The address of the stablecoin contract.
     */
    constructor(address _stablecoinAddress) {
        stablecoinAddress = _stablecoinAddress;
    }

    /**
     * @dev Allows a lender to grant credit by transferring a specific amount of stablecoin to a borrower.
     * The lender must have previously approved this contract to spend the specified amount on their behalf.
     * @param _lender The address of the lender.
     * @param _borrower The address of the borrower.
     * @param _amount The amount of stablecoin to be loaned.
     */
    function grantCredit(address _lender, address _borrower, uint256 _amount) public {
        require(IERC20(stablecoinAddress).transferFrom(_lender, _borrower, _amount), "Transfer failed");
        emit CreditGranted(_lender, _borrower, _amount);
    }

    /**
     * @dev Allows updating the stablecoin address. This function can be restricted or managed as needed.
     * @param _newStablecoinAddress The new address of the stablecoin contract.
     */
    function updateStablecoinAddress(address _newStablecoinAddress) public {
        // Add any access control or validation logic if necessary
        stablecoinAddress = _newStablecoinAddress;
    }
}