# Tokenization (Current Research)

## Enhancing Tax Compliance: Exploring the Potential of Smart Contracts regarding VAT Fraud

### Smart Contracts
#### [ReceiptTokenContract](VAT%20fraud/ReceiptTokenContract.sol)
#### [VATToken_CH](VAT%20fraud/VATToken_CH.sol)
#### [VATToken_DE](VAT%20fraud/VATToken_DE.sol)

### Audience
- **Tax Authorities**
- **Governments**
- **Companies**
- **Audit Firms**
- **Policy Makers**
- **Students & Researchers**

### Description
The Tokenization Team is developing a prototype for a smart contract solution for the Value-Added-Tax (VAT) system in Switzerland and the border to Germany. The objective of this prototype is to prevent VAT fraud, enhance system efficiency, transparency and security, and thus aid the government in ensuring their compliance and to safeguard revenue.
Similar to Ainsworth et al. (2016), the team proposed incorporating a VATToken (ERC20 Token) into their smart contracts solution for VAT payments. Moreover, a ReceiptToken (ERC721) can be generated after a successful VAT payment to the government, which provides an unfalsifiable proof of the transaction for both buyers and sellers of goods or services.

<img src="VAT Fraud/Graphics/Prototype.png" width="650"/>

### Assumptions
- Deployment on sepolia testnet (ethereum blockchain): Assumption of integrity of the blockchain data (in a real world adoption a private blockchain would be expedient)
- Government collaboration
- Adoption by businesses
- Scalability of the blockchain

### Open Issues
- Exchange rate oracle CHF-EUR for precise currency swaps

### Contributors
- <a href="https://github.com/darioganz" style="text-decoration: none; color: black;">Dario Ganz</a>
- <a href="https://github.com/SamuelClauss" style="text-decoration: none; color: black;">Samuel Clauss</a>
