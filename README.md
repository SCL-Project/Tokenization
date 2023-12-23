# Tokenization (Current Research)

## Prototype to enhance VAT compliance and mitigate VAT Fraud
- **Scope:** Switzerland & Germany

The objective of this prototype is to prevent VAT fraud, enhance system efficiency, transparency and security, and thus aid the government in ensuring their compliance and to safeguard revenue. Similar to Ainsworth et al. (2016), the team proposed incorporating a VATToken (ERC20 Token) for each country into their smart contracts solution for VAT payments. Moreover, a ReceiptToken (ERC721) can be generated after a successful VAT payment to the government, which provides an unfalsifiable proof of the transaction for both buyers and sellers of goods or services. In cross-border transactions and simple crossings of the border, the CrossBorderContract is required to be able to transfer goods.

## Overview
#### [Whitepaper](Whitepaper.md): The fundamentals behind the smart contracts
### Smart Contracts
#### [ReceiptTokenContract](VAT%20fraud/ReceiptTokenContract.sol): Creates a digital ReceiptToken for the buyer & seller
#### [VATToken_CH](VAT%20fraud/VATToken_CH.sol): Contract to pay VAT in Switzerland
#### [VATToken_DE](VAT%20fraud/VATToken_DE.sol): Contract to pay VAT in Germany
#### [CrossBorderContract](VAT%20fraud/CrossBorderContract.sol): Contract for cross-border transactions and simple border crossings 

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
- Deployment on sepolia testnet (ethereum blockchain): Assumption of integrity of the blockchain data (in a real world adoption a private blockchain would be expedient)
- Only 1 VAT rate per country
- Government collaboration
- Adoption by businesses
- Scalability of the blockchain
- No corrupt government entities

### Open Issues
- Exchange rate oracle CHF-EUR for precise currency swaps
- Integration of different VAT rates per country

### Contributions
🌟 Your Contributions are Valued in the VAT Fraud Repository! 🌟
If you have any ideas, suggestions, or bug reports, please open an issue or submit a pull request.

### Contributors
- <a href="https://github.com/darioganz" style="text-decoration: none; color: black;">Dario Ganz</a>
- <a href="https://github.com/SamuelClauss" style="text-decoration: none; color: black;">Samuel Clauss</a>
