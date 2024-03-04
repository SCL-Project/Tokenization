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
    // Hardcoded address of the USDC contract on Mumbai testnet
    address public stablecoinAddress = 0x9999f7Fea5938fD3b1E26A12c3f2fb024e194f97;

    // Event to emit when a credit is granted successfully
    event CreditGranted(address indexed lender, address indexed borrower, uint256 amount);

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

    // Removed the updateStablecoinAddress function to prevent changing the hardcoded address
}