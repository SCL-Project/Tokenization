// ***************************************************************************************************************
// SPDX-License-Identifier: MIT
/// @title P2PLending Contract
/// @author Dario Ganz
// Smart Contracts Lab, University of Zurich
// Created: March 15, 2024
// ***************************************************************************************************************
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

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

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     *      allowed to spend on behalf of `owner` through {transferFrom}.
     *      This is zero by default. This value changes when {approve} or
     *      {transferFrom} are called.
     * @param owner The address which owns the funds
     * @param spender The address which will spend the funds
     * @return uint256 specifying the number of tokens still available for the spender
     */
    function allowance(address owner, address spender) external view returns (uint256);
}

//-------------------------------------------P2PLendingContract----------------------------------------------

contract P2PLending is Ownable {
    address public stablecoinAddress;
    bool private locked; // Reentrancy guard

    /**
     * @dev Constructor to initialize the P2PLending Contract
     */
    constructor(address _stablecoinAddress) Ownable(msg.sender) {
        setStablecoinAddress(_stablecoinAddress);
    }

//------------------------------------------------Modifier----------------------------------------------------

    /**
     * @dev Modifier that locks a function by setting a private state variable before the function executes, 
     *      and unsets it after the function runs. It is used to prevent a function from being called again 
     *      while it is still executing, protecting against reentrancy attacks
     */
    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }    

//------------------------------------------------Events-----------------------------------------------------

    /** @dev Emitted when a new credit has been granted from a lender
     *  @param lender The wallet address of the lender of the credit
     *  @param borrower The wallet address of the borrower
     *  @param amount The amount borrowed
     *  @param dueDate The date where the loan needs to be paid back
    */
    event CreditGranted(address indexed lender, address indexed borrower, uint256 amount, uint256 dueDate);
    
    /** @dev Emitted when a new credit has been repaid by a borrower
     *  @param lender The wallet address of the lender of the credit
     *  @param borrower The wallet address of the borrower
     *  @param amount The amount borrowed
    */
    event CreditRepaid(address indexed borrower, address indexed lender, uint256 amount);

//------------------------------------------------Structs----------------------------------------------------

    /**
     *  @dev Struct to store the details the lending
     *  @param lender The wallet address of the lender giving the credit
     *  @param amount The amount of the lending
     *  @param dueDate The date where the loan needs to be paid back
     */
    struct Loan {
        address lender;
        uint256 amount;
        uint256 dueDate;
    }

//------------------------------------------------Mapping----------------------------------------------------

    /**
     *  @dev Mapping to store the current loans given
     */  
    mapping(address => Loan) private loans;

//-----------------------------------------------Functions---------------------------------------------------

    /**
     *  @dev Sets the address of the stablecoin contract to choose with which Stablecoin
     *       the transfer takes place. Can only be called by the contract owner
     *  @param _stablecoinAddress The address of the ERC-20 stablecoin contract
     */
    function setStablecoinAddress(address _stablecoinAddress) public onlyOwner {
        require(_newStablecoinAddress != address(0), "Invalid address");
        stablecoinAddress = _newStablecoinAddress;
    }

    /**
     * @dev Returns the loan details for the caller of this function.
     * @return lender The address of the lender.
     * @return amount The amount of the loan.
     */
    function getMyLoan() public view returns (address lender, uint256 amount, uint256 dueDate) {
        require(loans[msg.sender].amount > 0, "No outstanding loan");
        return (loans[msg.sender].lender, loans[msg.sender].amount, loans[msg.sender].dueDate);
    }

    /**
     * @dev Allows a lender to grant credit by transferring a specific amount of stablecoin to a borrower.
     *      The lender must have previously approved this contract to spend the specified amount on their behalf
     * @param _lender The address of the lender
     * @param _borrower The address of the borrower
     * @param _amount The amount of stablecoin to be loaned
     */
    function grantCredit(address _lender, address _borrower, uint256 _amount, uint256 _dueDate) public noReentrant {
        require(loans[_borrower].amount == 0, "Active loan exists"); // Prevent loan overwriting
        uint256 allowance = IERC20(stablecoinAddress).allowance(_lender, address(this));
        require(allowance >= _amount, "Allowance too low"); // Check allowance

        require(IERC20(stablecoinAddress).transferFrom(_lender, _borrower, _amount), "Transfer failed");
        loans[_borrower] = Loan(_lender, _amount, _dueDate); // Include due date
        emit CreditGranted(_lender, _borrower, _amount, _dueDate);
    }
    
    /**
     * @dev Allows a borrower to repay their loan. The stablecoin is transferred from the borrower back to the lender.
     *      The loan is then marked as repaid and the loan details are deleted
     */
    function repayCredit() public noReentrant {
        Loan memory loan = loans[msg.sender];
        require(loan.amount > 0, "No outstanding loan");
        require(block.timestamp <= loan.dueDate, "Loan due date passed"); // Check for due date before allowing repayment

        require(IERC20(stablecoinAddress).transferFrom(msg.sender, loan.lender, loan.amount), "Repayment failed");
        emit CreditRepaid(msg.sender, loan.lender, loan.amount);
        delete loans[msg.sender];
    }
}