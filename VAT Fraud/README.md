# Tokenization (Current Research)

## Prototype to enhance VAT compliance and mitigate VAT Fraud
- **Scope:** Switzerland & Germany

The objective of this prototype is to prevent VAT fraud, enhance system efficiency, transparency and security, and thus aid the government in ensuring their compliance and to safeguard revenue. Similar to Ainsworth et al. (2016), the team proposed incorporating a VATToken (ERC20 Token) for each country into their smart contracts solution for VAT payments. Moreover, a ReceiptToken (ERC721) can be generated after a successful VAT payment to the government, which provides an unfalsifiable proof of the transaction for both buyers and sellers of goods or services. In cross-border transactions and simple crossings of the border, the CrossBorderContract is required to be able to transfer goods.

## Overview
#### [Whitepaper](Whitepaper.md): The fundamentals behind the smart contracts
### Smart Contracts
#### [ReceiptTokenContract](VAT%20Fraud/ReceiptTokenContract.sol): Creates ReceiptTokens for the buyer & seller
#### [VATTokenContract Switzerland](VAT%20Fraud/VATToken_CH.sol): Contract to pay VAT in Switzerland
#### [VATTokenContract Germany](VAT%20Fraud/VATToken_DE.sol): Contract to pay VAT in Germany
#### [CrossBorderContract](VAT%20Fraud/CrossBorderContract.sol): Contract for cross-border transactions
#### [Oracle](VAT%20Fraud/Oracle.sol): Contract to similate an oracle for the exchange rates and VAT rates at the address 0x1ee17f86785fB0Ea5ff5B5D59DCeA41713eCEcF8

### NatSpec Format
- **[Solidity Documention](https://docs.soliditylang.org/en/latest/natspec-format.html)**
- **@title:** Title of the contract
- **@authors:** Authors of the contract
- **@dev:** Explains to the end user all extra details (inlcudes @notice to safe space)
- **@param:** documents a parameter
- **@return:** documents the retunr variables of a contract's function

### Audience
- **Tax Authorities**
- **Governments**
- **Companies**
- **Audit Firms**
- **Policy Makers**
- **Students & Researchers**

### Assumptions
- Deployment on sepolia testnet (ethereum blockchain): Assumption of integrity of the blockchain data (in a real-world adoption a private blockchain would be expedient)
- Only 1 VAT rate per country
- Government collaboration
- Adoption by businesses
- Scalability of the blockchain
- No corrupt government entities

### Open Issues
- Exchange rate (CHF-EUR) oracle for precise currency swaps
- VAT rate oracle for reliable VAT rates and to add multiple VAT rates per country depending on the industry
- getNFTData and getCompany are currently public so everybody can access the data (safety concerns)

## Installation to Compile, Deploy & Interact with the Contracts

To interact with the `Oracle`, `ReceiptTokenContract`, `CrossBorderContract`, `VATToken_CH` and `VATToken_DE` in Remix, follow these steps:
### 1. Open Remix IDE
   - Go to [Remix Ethereum IDE](https://remix.ethereum.org/).

### 2. Create the Contract Files
   - In the File Explorer pane of Remix, create new files for each contract.
   - Copy and paste the Solidity code of each respective contract into these files.

### 3. Compile the Contracts
   - Go to the Solidity Compiler tab and select the appropriate compiler version (e.g., `0.8.20`).
   - Click the 'Compile' button for each contract file.

### 4. Deploy the Contracts
   - Switch to the 'Deploy & Run Transactions' tab.
   - Connect to your chosen Ethereum environment using the 'Environment' dropdown.
   - Select the contract you wish to deploy from the 'Contract' dropdown.
   - Enter any necessary constructor parameters
   - Click 'Deploy' to deploy each contract. 
   - After deployment, the contracts will appear in the 'Deployed Contracts' section at the bottom of the panel.

#### 4.1 Order of Deployment
Follow this sequence for deploying your contracts:
  1. `ReceiptTokenContract`
  2. `VATToken_CH` & `VATToken_DE`
  3. `CrossBorderContract`
  
#### 4.2 Connecting the Deployed Contracts
Establish connections between your contracts with these steps:
  1. In the `VATToken_CH` & `VAToken_De` contract, call the `setCBCAddress` function using the address of the `CrossBorderContract` and call in each of the two contracts the setVAT_DE/CH_Address and set the Address of the other VATToken Contract.
  2. In the `ReceiptTokenContract`, invoke `setVAT_DE_Contract` & `setVAT_CH_Contract` functions with the corresponding contract addresses.

#### 4.3 Further Steps
Complete the setup with the following actions:
  1. Call the `SetTokenCredit` function in the `VATToken` contract of the seller's country, providing some tokens for the respective seller.
  2. Sellers need to execute the `buyVATTokens` function to access tokens from the `TokenCredit`.
  3. To create ReceiptTokens, sellers should use the `CreateReceiptToken` function. This will send VATTokens to the government and generate the ReceiptTokens.

### 6. Linking Contracts
   - Since the 3 contracts need to interact with each other (e.g., `ReceiptTokenContract` needs the address of `VATTokenContract`), ensure you copy the deployed contract addresses and set them using the appropriate functions in the respective contracts.

### 7. Interact with the Contracts
   - In the 'Deployed Contracts' section, you can interact with each contract's functions.
   - Use the provided fields and buttons to call functions of the contract, such as creating tokens, transferring tokens across the border or refund taxes.

### Contributions
🌟 Your Contributions are Valued in the VAT Fraud Repository! 🌟  
If you have any ideas, suggestions, or bug reports, please open an issue or submit a pull request.

## License
This project is licensed under the MIT License

### Contributors
- <a href="https://github.com/darioganz" style="text-decoration: none; color: black;">Dario Ganz</a>
- <a href="https://github.com/SamuelClauss" style="text-decoration: none; color: black;">Samuel Clauss</a>
