# P2PLending Contract 1.4

## Overview
The P2PLending contract provides a decentralized solution for peer-to-peer (P2P) lending of ERC20 stablecoins. It allows users to grant and repay credits securely and automatically, without the need for intermediaries.

## Features
- **Reentrancy Protection**: Secured against reentrancy attacks for critical functions
- **ERC20 Compatibility**: Works with any ERC20-compliant stablecoin for lending purposes
- **Ownership Management**: Utilizes OpenZeppelin's `Ownable` for owner-specific functions
- **User Registration System**: Users must register to participate in lending activities, enhancing security and allowing for better management of participants
- **Administrative Controls**: The contract owner can register or unregister users and lock or unlock addresses, providing administrative control over the platform's operation
- **Loan Tracking**: Maintains an internal ledger of active loans with amounts and due dates
- **Event Logging**: Emits events for credit granting and repayment for transparency and auditability
- **Automated Transfer**: Streamlines the process of transferring tokens between lender and borrower

## Contract Deployment
To deploy the contract, the address of the ERC20 stablecoin must be provided. This address is set during deployment and can be updated by the contract owner if necessary.

## Modifiers
### noReentrant
Secures functions against reentrancy. No function can be re-entered while it's still executing

### isRegistered
Ensures that only registered users can interact with certain funcitons of the contract

### addressNotLocked
Prevents locked users from performing actions that could affect the contract's integrity

## Functions
### setStablecoinAddress
Allows the contract owner to set the address of the ERC20 stablecoin to be used for lending.

### getMyLoan
Returns the details of the caller's active loan

### grantCredit
Allows a lender to initiate a loan by transferring a specified amount of stablecoin to a borrower. The lender must approve the contract to spend the tokens beforehand

### repayCredit
Enables the borrower to repay the loan. The stablecoin is transferred back to the lender, and the loan is marked as repaid

## Events
### CreditGranted
Emitted when a loan is successfully granted

## CreditRepaid
Emitted when a loan is successfully repaid

## Security Practices
The contract employs standard security practices, including the use of a registration, require statements for validation and the noReentrant modifier to prevent reentrancy attacks.
All state-changing operations are protected to ensure that only valid and intended actions are executed.

## Versions
### P2PLending1.1
Introduces blockchain-based contracts represented as ERC721 tokens, allowing for the unique representation of lender and borrower agreements as non-fungible tokens on the blockchain and automated transactions.
### P2PLending1.2
Removed ERC721 tokens to save on gas fees. Only transaction embedded in the smart contract due to the fact that the smart contract is recognised by Swiss law
### P2PLending1.3
Added a function to change the current stablecoin contract used for the transaction of the loan. Added the allowance function in the IERC20 Interface and the noReentrant modifier. Additionally added the due date of the loan to the functions.
### P2PLending1.4
Added functionality of register and lock addresses to prevent unauthorised use and potential fraud.

## Deployment and Interaction
The contract should be deployed on the Ethereum mainnet or testnets like Sepolia. Interaction with the contract can be done via Ethereum wallets like MetaMask or programmatically using libraries like web3.js or ethers.js.
  
*Before a loan can be granted, lenders must approve the contract to spend the loan amount on their behalf*

## Versioning
The contract is written in Solidity ^0.8.20, and it's recommended to use this compiler version or newer to ensure compatibility and incorporate security fixes.

## License
The project is released under the MIT License.
