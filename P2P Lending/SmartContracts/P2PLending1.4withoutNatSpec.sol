// ***************************************************************************************************************
// SPDX-License-Identifier: MIT
/// @title P2PLending Contract
/// @author Dario Ganz
// Smart Contracts Lab, University of Zurich
// Created: March 25, 2024
// ***************************************************************************************************************
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

//-----------------------------------------------Interface---------------------------------------------------

interface IERC20 {

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

//-------------------------------------------P2PLendingContract----------------------------------------------

contract P2PLending is Ownable {
    address public stablecoinAddress;
    bool private locked; // Reentrancy guard

    constructor(address _stablecoinAddress) Ownable(msg.sender) {
        setStablecoinAddress(_stablecoinAddress);
    }

//------------------------------------------------Modifier----------------------------------------------------

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    modifier isRegistered() {
        require(registeredAddresses[msg.sender], "User not registered");
        _;
    }

    modifier addressNotLocked(address _user) {
        require(!lockedAddresses[_user], "Address is locked");
        _;
    }

//------------------------------------------------Events-----------------------------------------------------

    event CreditGranted(address indexed lender, address indexed borrower, uint256 amount, uint256 dueDate);
    event CreditRepaid(address indexed borrower, address indexed lender, uint256 amount);

//------------------------------------------------Structs----------------------------------------------------

    struct Loan {
        address lender;
        uint256 amount;
        uint256 dueDate;
    }

//------------------------------------------------Mappings---------------------------------------------------
 
    mapping(address => Loan) private loans;  
    mapping(address => bool) public registeredAddresses;
    mapping(address => bool) public lockedAddresses;

//-----------------------------------------------Functions---------------------------------------------------

    function register() public addressNotLocked(msg.sender) {
        registeredAddresses[msg.sender] = true;
    }

    function unregister() public isRegistered {
        registeredAddresses[msg.sender] = false;
    }

    function adminRegister(address _user) public onlyOwner addressNotLocked(_user) {
        registeredAddresses[_user] = true;
    }

    function adminUnregister(address _user) public onlyOwner {
        registeredAddresses[_user] = false;
    }

    function lockAddress(address _user) public onlyOwner {
        if (registeredAddresses[_user]) {
        registeredAddresses[_user] = false;
    }
        lockedAddresses[_user] = true;
    }

    function unlockAddress(address _user) public onlyOwner {
        lockedAddresses[_user] = false;
    }

    function setStablecoinAddress(address _stablecoinAddress) public onlyOwner {
        require(_stablecoinAddress != address(0), "Invalid address");
        stablecoinAddress = _stablecoinAddress;
    }

    function getMyLoan() public view returns (address lender, uint256 amount, uint256 dueDate) {
        require(loans[msg.sender].amount > 0, "No outstanding loan");
        return (loans[msg.sender].lender, loans[msg.sender].amount, loans[msg.sender].dueDate);
    }

    function grantCredit(address _lender, address _borrower, uint256 _amount, uint256 _dueDate) public noReentrant  addressNotLocked(msg.sender) {
        require(registeredAddresses[_borrower], "Borrower not registered");
        require(loans[_borrower].amount == 0, "Active loan exists"); // Prevent loan overwriting
        uint256 allowance = IERC20(stablecoinAddress).allowance(_lender, address(this));
        require(allowance >= _amount, "Allowance too low"); // Check allowance

        require(IERC20(stablecoinAddress).transferFrom(_lender, _borrower, _amount), "Transfer failed");
        loans[_borrower] = Loan(_lender, _amount, _dueDate);
        emit CreditGranted(_lender, _borrower, _amount, _dueDate);
    }
    
    function repayCredit() public noReentrant {
        Loan memory loan = loans[msg.sender];
        require(loan.amount > 0, "No outstanding loan");
        require(block.timestamp <= loan.dueDate, "Loan due date passed"); // Check for due date before allowing repayment

        require(IERC20(stablecoinAddress).transferFrom(msg.sender, loan.lender, loan.amount), "Repayment failed");
        emit CreditRepaid(msg.sender, loan.lender, loan.amount);
        delete loans[msg.sender];
    }
}