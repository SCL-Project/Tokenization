// ***************************************************************************************************************
// SPDX-License-Identifier: MIT
/// @title ReceiptTokenContract
/// @author Samuel Clauss & Dario Ganz
// Smart Contracts Lab, University of Zurich
// Created: December 20, 2023
// ***************************************************************************************************************
// Read the Whitepaper https://github.com/SCL-Project/Tokenization/blob/main/Whitepaper.md
// ***************************************************************************************************************
pragma solidity ^0.8.20;

import "./Oracle.sol";
import "./VATToken_DE.sol";
import "./VATToken_CH.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ReceiptTokenContract is ERC721, ERC721Burnable, Ownable {
    uint56 private _nextTokenId = 1;
    VATToken_CH public VAT_CH_Contract;
    VATToken_DE public VAT_DE_Contract;
    Oracle public OracleContract = Oracle(0xE0A74b0171615099B3aeef9456eFcE181aF9aE8E);
    address initialOwner;

    /**
     * @dev Constructor to initialize the ReceiptTokenContract
     * @param _initialOwner Address of the owner
     */
    constructor(address _initialOwner) 
            ERC721("ReceiptToken", "RCT")
            Ownable(_initialOwner)
        {
            initialOwner = _initialOwner;
        }
    

    //------------------------------------------------Structs-----------------------------------------------------

    /**
     * @dev Struct to store information of the ReceiptToken
     * @param Type The type of token ('SellerToken' or 'BuyerToken')
     * @param buyer The buyer (company name) of a good involved in the transaction
     * @param seller The seller (company name) of a good involved in the transaction
     * @param good The specific good or service that is sold
     * @param currency The currency of the transaction
     * @param country_of_sale The country of the selling, important for shippings across the border
     * @param current_country The country where the good is located at the moment
     * @param quantity The quantity of goods sold
     * @param total_price The total price of the transaction
     * @param VAT_amount The amount of VAT to be paid in the transaction
     * @param TwinTokenID ID of the twin token
     * @param isRefunded Indicates whether the VAT has been refunded or not
     */
    struct Receipt {
        string Type;
        string buyer;
        string seller;
        string good;
        string currency;
        string country_of_sale;
        string current_country;
        uint32 quantity;
        uint40 total_price;
        uint40 VAT_amount;
        uint56 TwinTokenID;
        bool isRefunded;
    }

    /**
     * @dev Struct to store the details about registered companies
     * @param isRegistered Indicates if the company is already registered
     * @param name The name of the company
     * @param UID The unique identifier of the company
     */
    struct Company {
        bool isRegistered;
        string name;
        string UID;
    }

    /**
     * @dev Struct to store the used percentage of used products to produce and sell another good.
     *      Is designed to make the supply chain more transparent
     * @param TokenID The tokenID of the product bought
     * @param UsagePercentage The percentage of the product used in the transaction for a further processed good
     */
    struct UsedProduct {
        uint56 TokenID;
        uint8 UsagePercentage;
    }

    //------------------------------------------------Mappings----------------------------------------------------

    /**
     * @dev Mapping to store data of Receipt associated with a tokenID
     */
    mapping (uint56 => Receipt) private NFTData;

    /**
     * @dev Mapping to store company data associated with an address
     */
    mapping (address => Company) private Companies;

    /**
     * @dev Mapping to store information about the used percentage of the products used for a good.
     *      Important for the refundTaxes function of the VATTokenContract
     */
    mapping (uint56 => UsedProduct[]) private UsedProducts; 


    //------------------------------------------------Events------------------------------------------------------
    
    /** @dev Emitted when a new SellerToken is created for a company. This logs the company's address and the 
     *       unique identifier of the SellerToken
     * @param company The address of the company for which the SellerToken is created
     * @param tokenID The unique identifier of the created SellerToken
     */
    event SellerTokenCreated(address company, uint56 tokenID);

    /** @dev Emitted when a new BuyerToken is created for a company. This logs the company's address and the unique 
     *       identifier of the BuyerToken
     *  @param company The address of the company for which the BuyerToken is created
     *  @param tokenID The unique identifier of the created BuyerToken
    */
    event BuyerTokenCreated(address company, uint56 tokenID);

    /** @dev Emitted when the end of a supply chain is reached, indicating no further actions are expected for 
     *       the token. Signals the selling to and end consumer. Logs the unique identifier of the token
     *  @param tokenID The unique identifier of the SellerToken reaching the end of the supply chain
     */
    event EndOfChain(uint56 tokenID);

    //------------------------------------------------Modifier----------------------------------------------------

    /**
     * @dev Ensures that the function can only be called by registered companies that are not locked or the 
     *      owner himself
     */
    modifier onlyCompanies() {
        require(Companies[msg.sender].isRegistered, "Only registered Companies");
        _;
    }

    /**
     * @dev Ensures that the function can only be called by Swiss and German government entities
     */
    modifier onlyGovernment() {
        require(msg.sender == initialOwner || msg.sender == address(this) || msg.sender == address(VAT_DE_Contract) 
        || msg.sender == address(VAT_CH_Contract), "Only Government Authorities");
        _;
    }
    
    /**
     * @dev Ensures that the function can only be called by the CrossBorderContract
     */
    modifier onlyCrossBorderContract() {
        require(msg.sender == VAT_CH_Contract.getCBCAddress());
        _;
    }
    
    //--------------------------------------------HelperFunctions-------------------------------------------------
    
    /**
     * @dev Sets the setVATToken_Contracts contract to the provided address and marks it as set.
     *      Can only be called by the contract owner
     * @param _VATToken_DE The new address of the VATToken_DE contract
     * @param _VATToken_CH The new address of the VATToken_CH contract
     */
    function setVATToken_Contracts(address _VATToken_CH, address _VATToken_DE) external onlyOwner {
        VAT_DE_Contract = VATToken_DE(_VATToken_DE);
        VAT_CH_Contract = VATToken_CH(_VATToken_CH);
    }


    /**
     * @dev Retrieves the data associated with a specific tokenID of a ReceiptToken (NFT)
     * @param _tokenId The ID of the ReceiptToken to retrieve data for
     * @return Receipt The struct containing the data of the ReceiptToken
     */
    function getNFTData(uint56 _tokenId) public view returns(Receipt memory) {
        return NFTData[_tokenId];
    }

    /** 
     * @dev Retrieves the registration status, name, and unique identifier (UID) for a company given its address
     * @param _address The address of the company to retrieve data for
     * @return isRegistered Indicates whether the company is registered
     * @return name The name of the company
     * @return UID The unique identifier for the company
     */
    function getCompany(address _address) public view returns(bool, string memory, string memory) {
        return (Companies[_address].isRegistered,
                Companies[_address].name,
                Companies[_address].UID);
    }

    //-----------------------------------------------Functions----------------------------------------------------
    
    /**
     * @dev Adds a used product to a specific token. This function ensures that the caller is the owner of both 
     *      the 'SellerToken' and the 'Buyertoken'. It also checks that the tokens have the correct types 
     *      ('SellerToken' and 'BuyerToken') for the operation. This is used to associate one or multiple
     *      'BuyerToken' (and the usage percentages) with a 'SellerToken' in the supply chain. Therefore 
     *      companies can use it as a prove for the input tax refund
     * @param _tokenID The ID of the 'SellerToken' to which the _productTokenID is being added
     * @param _productTokenID The ID of a 'BuyerToken' from a product that is used for the good to be sold
     * @param _usedPercentage The percentage of the product token's usage for the sale of a good
     */
    function addUsedProduct(uint56 _tokenID, uint56 _productTokenID, uint8 _usedPercentage) external {
        require(ownerOf(_tokenID) == msg.sender && ownerOf(_productTokenID) == msg.sender, "Not the Tokenowner");
        require(
            keccak256(abi.encodePacked(NFTData[_tokenID].Type)) == keccak256(abi.encodePacked("SellerToken")) &&
            keccak256(abi.encodePacked(NFTData[_productTokenID].Type)) == keccak256(abi.encodePacked("BuyerToken")),
            "Not correct Token Type!"
            ); 

        UsedProduct memory newusedProduct = UsedProduct(
            _productTokenID,
            _usedPercentage
        );
        UsedProducts[_tokenID].push(newusedProduct);
    }

    /**
     * @dev Removes a used product token ('BuyerToken') from a specific token. This function ensures that the caller
     *      is the owner of the 'SellerToken'. It searches for the product token within the list of used products
     *      associated with the 'SellerToken' and removes it if found
     * @param _tokenID The ID of the 'SellerToken' from which the _productTokenID is being removed
     * @param _productTokenID The ID of a 'BuyerToken' from a product that is used for the good to be sold
     * @return bool Returns true if the product token is successfully removed, false otherwise
     */
    function removeUsedProduct(uint56 _tokenID, uint56 _productTokenID) external returns(bool) {
        require(ownerOf(_tokenID) == msg.sender, "Not the Tokenowner");
        for (uint24 i = 0; i < UsedProducts[_tokenID].length; i++) {
            if (UsedProducts[_tokenID][i].TokenID == _productTokenID) {
                // Move the last element to the position of the element to delete
                UsedProducts[_tokenID][i] = UsedProducts[_tokenID][UsedProducts[_tokenID].length - 1];
                // Remove the last element
                UsedProducts[_tokenID].pop();
                return true; // Exit the function after removing the element
            }
        }
        return false;
    }

    /**
     * @dev Retrieves the list of used product tokens and their usage percentages associated with a specific 
     *      'SellerToken' (_tokenID). This is used to understand how different product tokens ('BuyerTokens')
     *      contribute to the good sold represented by the 'SellerToken'
     * @param _tokenID The ID of the 'SellerToken' for which used products are being queried
     * @return uint56[] An array of tokenIDs of the used products
     * @return uint8[] An array of the usage percentages corresponding to each used product token
     */
    function getUsedProducts(uint56 _tokenID) external onlyGovernment view returns(uint56[] memory, uint8[] memory) {
        uint56[] memory tokenIDs = new uint56[](UsedProducts[_tokenID].length);
        uint8[] memory percentages = new uint8[](UsedProducts[_tokenID].length);
        for (uint24 i = 0; i < UsedProducts[_tokenID].length; i++) {
            uint56 a = UsedProducts[_tokenID][i].TokenID;
            uint8 b = UsedProducts[_tokenID][i].UsagePercentage;
            tokenIDs[i] = a;
            percentages[i] = b;
        }
    return (tokenIDs, percentages);
    }

    /**
     * @dev Change the refund status in the data of the token to prevent double refundings
     * @param _tokenID The ID of the 'SellerToken' to prove that the good has not been 
     *                 consumed but processed and sold
     */
    function changeRefundStatus(uint56 _tokenID) onlyGovernment external {
        NFTData[_tokenID].isRefunded = true;
    }

    /**
     * @dev Changes the current country associated with a specific tokenID.
     *      This function can only be called by the authorized CrossBorderContract
     * @param _tokenID The ID of the token for which the current country has to be changed
     * @param _country The new country associated with the tokenID
 */
    function changeCurrentCountry(uint56 _tokenID, string memory _country) external onlyCrossBorderContract() {
        NFTData[_tokenID].current_country = _country;
    }

    /**
     * @dev Companies can be registered by the contract owner (onlyOwner) and are stored in the Companies mapping
     * @param _address Address of the company to be registered
     * @param _name Name of the company
     * @param _UID The unique identifier of the company
     */
    function RegisterCompany(address _address, string memory _name, string memory _UID) external onlyOwner {
        require(!Companies[_address].isRegistered, "Company already registered");
        Company memory newCompany = Company(true, _name, _UID);
        Companies[_address] = newCompany;
    }

    /**
     * @dev Companies can be deleted by the contract owner if they are registered. If VAT Fraud is detected, the
     *      company can straight be excluded from the system
     * @param _address Address of the company to be deleted
     */
    function DeleteCompany(address _address) external onlyOwner {
        require(Companies[_address].isRegistered, "Company already registered");
        delete Companies[_address];
    }

    /**
     * @dev Companies can change their name and UID via the contract owner and the new name and UID is updated into
     *      the mapping
     * @param _address Address of the company that changes its name
     * @param _name Name of the company to be changed
     * @param _UID The unique identifier of the company to be changed

     */
    function ChangeCompany(address _address, string memory _name, string memory _UID) external onlyOwner {
        require(Companies[_address].isRegistered, "Company not registered");
        Companies[_address].name = _name;
        Companies[_address].name = _UID;
    }

    /**
     * @dev Mints a new token according to the ERC721 standard and assigns it to a specified address. This method
     *      includes safety checks to prevent common pitfalls in minting. The tokenID is automatically set and the 
     *      function increments the tokenID counter for each new token
     * @param to The address to which the newly minted token will be assigned
     * @return uint56 The tokenID of the newly minted token
     */
    function safeMint(address to) public onlyGovernment returns(uint56) {
        uint56 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        return tokenId;
    }

    /**
     * @dev Creates receipt tokens for a transaction involving a buyer and a seller (or only a seller at the end 
     *      of the supply chain). This function mints two tokens: one representing the seller's side of the transaction 
     *      and another for the buyer's side ('SellerToken and BuyerToken'). At the end of the chain only a 'SellerToken 
     *      is minted and the good goes to the end consumer. The function checks that neither the buyer nor the seller
     *      is locked. The VAT is calculated and is automatically paid before the tokens can be minted. Therefore 
     *      VAT-fraud can be prevented
     * @param _buyer The name of the buyer company of the transaction
     * @param _seller The name of the seller company of the transaction
     * @param _good The description of the good or service being transacted
     * @param _country_of_sale The country in which the sale takes place
     * @param _quantity The quantity of the good being transacted
     * @param _total_price The total price of the transaction
     * @param _buyerAddr The Address of the buyer
     */
    function createReceiptToken(
        string memory _buyer,
        string memory _seller,
        string memory _good,
        string memory _country_of_sale,
        uint32 _quantity,
        uint40 _total_price,
        address _buyerAddr
        ) external onlyCompanies {
        uint40 _VAT_amount = _total_price * OracleContract.getVATRate(_country_of_sale) / 1000;

        bool x;

        if (keccak256(abi.encodePacked(_country_of_sale)) == keccak256(abi.encodePacked("Switzerland"))) {
            x = VAT_CH_Contract.payTaxes(msg.sender, _VAT_amount);
        } else if (keccak256(abi.encodePacked(_country_of_sale)) == keccak256(abi.encodePacked("Germany"))) {
            x = VAT_DE_Contract.payTaxes(msg.sender, _VAT_amount);
        } else {
            revert("Country not part of the system");
        }

        require(x, "VAT not paid");

        uint56 tokenID1 = this.safeMint(msg.sender);

        Receipt memory newReceipt1 = Receipt(
            "SellerToken",
            _buyer, 
            _seller, 
            _good,
            OracleContract.getCurrency(_country_of_sale),
            _country_of_sale,
            _country_of_sale,  
            _quantity, 
            _total_price, 
            _VAT_amount,
            0,
            false
        );
        NFTData[tokenID1] = newReceipt1;

        emit SellerTokenCreated(msg.sender, tokenID1);

        if (_buyerAddr != address(0)) {

            uint56 tokenID2 = this.safeMint(_buyerAddr);

            Receipt memory newReceipt2 = Receipt(
                "BuyerToken",
                _buyer, 
                _seller, 
                _good, 
                OracleContract.getCurrency(_country_of_sale),
                _country_of_sale, 
                _country_of_sale, 
                _quantity, 
                _total_price, 
                _VAT_amount,
                tokenID1,
                true
            );
            NFTData[tokenID2] = newReceipt2;
            NFTData[tokenID1].TwinTokenID = tokenID2;

            emit BuyerTokenCreated(_buyerAddr, tokenID2);

        } else {
            emit EndOfChain(tokenID1);
        }
    }
}
