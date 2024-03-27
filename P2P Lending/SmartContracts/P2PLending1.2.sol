// ***************************************************************************************************************
// SPDX-License-Identifier: MIT
/// @title P2PLending Contract
/// @author Dario Ganz
// Smart Contracts Lab, University of Zurich
// Created: February 26, 2024
// ***************************************************************************************************************
pragma solidity ^0.8.20;

//-----------------------------------------------Interface---------------------------------------------------

interface IERC20 {

    /**
     * @dev Transfers tokens from one address to another
     * @param sender The address from which the tokens will be debited
     * @param recipient The address to which the tokens will be credited
     * @param amount The number of tokens to transfer
     * @return bool indicating whether the operation was successful
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

//-------------------------------------------P2PLendingContract----------------------------------------------

contract P2PLending {
    // Hardcoded address of the USDC contract on Mumbai testnet
    address public stablecoinAddress = 0x9999f7Fea5938fD3b1E26A12c3f2fb024e194f97;

//------------------------------------------------Events-----------------------------------------------------

    /** @dev Emitted when a new credit has been granted from a lender
     *  @param lender The wallet address of the lender of the credit
     *  @param borrower The wallet address of the borrower
     *  @param amount The amount borrowed
    */
    event CreditGranted(address indexed lender, address indexed borrower, uint256 amount);

    /** @dev Emitted when a new credit has been repaid by a borrower
     *  @param lender The wallet address of the lender of the credit
     *  @param borrower The wallet address of the borrower
     *  @param amount The amount borrowed
    */
    event CreditRepaid(address indexed borrower, address indexed lender, uint256 amount);

//------------------------------------------------Structs----------------------------------------------------

    /**
     * @dev Struct to store the details of the lending
     * @param lender The wallet address of the lender giving the credit
     * @param amount The amount of the lending
     */
    struct Loan {
        address lender;
        uint256 amount;
    }

//------------------------------------------------Mappings---------------------------------------------------

    /**
     * @dev Mapping to store the current loans given
     */  
    mapping(address => Loan) private loans;

//-----------------------------------------------Functions---------------------------------------------------

    /**
     * @dev Returns the loan details for the caller of this function.
     * @return lender The address of the lender.
     * @return amount The amount of the loan.
     */
    function getMyLoan() public view returns (address lender, uint256 amount) {
        require(loans[msg.sender].amount > 0, "No outstanding loan");
        return (loans[msg.sender].lender, loans[msg.sender].amount);
    }

    /**
     * @dev Allows a lender to grant credit by transferring a specific amount of stablecoin to a borrower.
     *      The lender must have previously approved this contract to spend the specified amount on their behalf
     * @param _lender The address of the lender
     * @param _borrower The address of the borrower
     * @param _amount The amount of stablecoin to be loaned
     */
    function grantCredit(address _lender, address _borrower, uint256 _amount) public {
        require(IERC20(stablecoinAddress).transferFrom(_lender, _borrower, _amount), "Transfer failed");
        loans[_borrower] = Loan(_lender, _amount);
        emit CreditGranted(_lender, _borrower, _amount);
    }
    
    /**
     * @dev Allows a borrower to repay their loan. The stablecoin is transferred from the borrower back to the lender.
     *      The loan is then marked as repaid and the loan details are deleted
     */
    function repayCredit() public {
        Loan memory loan = loans[msg.sender];
        require(loan.amount > 0, "No outstanding loan");
        require(IERC20(stablecoinAddress).transferFrom(msg.sender, loan.lender, loan.amount), "Repayment failed");
        emit CreditRepaid(msg.sender, loan.lender, loan.amount);
        delete loans[msg.sender]; // Delete the loan after repayment
    }
}