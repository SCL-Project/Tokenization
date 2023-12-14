// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./VATToken_DE.sol";
import "./VATToken_CH.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/// @title ReceiptTokenContract
/// @author Samuel Clauss & Dario Ganz
contract ReceiptTokenContract is ERC721, ERC721Burnable, Ownable {
    uint64 private _nextTokenId = 1;
    VATToken_CH public VAT_CH_Contract;
    VATToken_DE public VAT_DE_Contract;
    bool VATToken_DE_set;
    bool VATToken_CH_set;

    /**
     * @dev Constructor to initialize the ReceiptTokenContract
     * @param initialOwner Address of the owner
     */
    constructor(address initialOwner) 
            ERC721("ReceiptToken", "RCT")
            Ownable(initialOwner)
        {}
    

    //----------------------------Structs-------------------------------

    /**
     * @dev Struct to store information of the ReceiptToken
     * @param Type The type of token ('SellerToken' or 'BuyerToken')
     * @param buyer, seller The parties involved in the transaction
     * @param good The specific good or service that is sold
     * @param country_of_sale The country of the selling, important for shippings across the border
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
        uint64 TwinTokenID;
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
     * @param TokenID The token ID of the product bought
     * @param UsagePercentage The percentage of the product used in the transaction for a further processed good
     */
    struct UsedProduct {
        uint64 TokenID;
        uint8 UsagePercentage;
    }


    //----------------------------Mappings-------------------------------


    /**
     * @dev Mapping to store data of Receipt associated with a tokenID
     */
    mapping (uint64 => Receipt) private NFTData;

    /**
     * @dev Mapping to store company data associated with an address
     */
    mapping (address => Company) private Companies;

    /**
     * @dev Mapping to store VAT-rates associated with the respective country
     */
    mapping (string => uint16) public VATRates;

    /**
     * @dev Mapping to track whether a company is locked
     */
    mapping (address => bool) private lockedAddresses;

    /**
     * @dev Mapping to store information about the used percentage of the products used for a good.
     *      Important for the refundTaxes function of the VATTokenContract
     */
    mapping (uint64 => UsedProduct[]) private UsedProducts; 


    mapping (string => string) private currency;


    //----------------------------Events---------------------------------

    event SellerTokenCreated(address company, uint256 tokenID);

    event BuyerTokenCreated(address company, uint256 tokenID);

    event EndOfChain(uint256 tokenID);

    event CurrencyNotRegistered(string country);


    //----------------------------Modifier-------------------------------

    /**
     * @dev Ensures that the function can only be called by registered companies that are not locked or the owner himself
     */
    modifier onlyCompanies() {
        require(Companies[msg.sender].isRegistered, "Only registered Companies can call this Function!");
        _;
    }

    //----------------------------HelperFunctions-------------------------

    function setVAT_DE_Contract(address _address) public onlyOwner {
        VAT_DE_Contract = VATToken_DE(_address);
        VATToken_DE_set = true;
    }

    function setVAT_CH_Contract(address _address) public onlyOwner {
        VAT_CH_Contract = VATToken_CH(_address);
        VATToken_CH_set = true;
    }

    function setCurrency(string memory _country, string memory _currency) public onlyOwner {
        currency[_country] = _currency;
    }

    function getNFTData(uint64 _tokenId) public view returns(Receipt memory) {
        return NFTData[_tokenId];
    }

    function getCompany(address _address) public onlyOwner view returns(bool, string memory, string memory) {
        return (Companies[_address].isRegistered,
                Companies[_address].name,
                Companies[_address].UID);
    }

    /**
     * @dev Adds a used product to a specific token. This function ensures that the caller is the owner of both the 'SellerToken' and the 'Buyertoken'. 
     *      It also checks that the tokens have the correct types ('SellerToken' and 'BuyerToken') for the operation.
     *      This is used to associate one or multiple 'BuyerToken' (and the usage percentages) with a 'SellerToken' in the supply chain.
     *      Therefore companies can use it as a prove for the input tax refund
     * @param _tokenID The ID of the 'SellerToken' to which the _productTokenID is being added
     * @param _productTokenID The ID of a 'BuyerToken' from a product that is used for the good to be sold
     * @param _usedPercentage The percentage of the product token's usage for the sale of a good
     */
    function addUsedProduct(uint64 _tokenID, uint64 _productTokenID, uint8 _usedPercentage) public {
        require(ownerOf(_tokenID) == msg.sender && ownerOf(_productTokenID) == msg.sender, "You are not the owner of this token!");
        require(
            keccak256(abi.encodePacked(NFTData[_tokenID].Type)) == keccak256(abi.encodePacked("SellerToken")) &&
            keccak256(abi.encodePacked(NFTData[_productTokenID].Type)) == keccak256(abi.encodePacked("BuyerToken")),
            "The Tokens do not have the correct Type!"
            ); 

        UsedProduct memory newusedProduct = UsedProduct(
            _productTokenID,
            _usedPercentage
        );
        UsedProducts[_tokenID].push(newusedProduct);
    }

    /**
     * @dev Removes a used product token ('BuyerToken') from a specific token. This function ensures that the caller is the owner of the 'SellerToken'. 
     *      It searches for the product token within the list of used products associated with the 'SellerToken' and removes it if found
     * @param _tokenID The ID of the 'SellerToken' from which the _productTokenID is being removed
     * @param _productTokenID The ID of a 'BuyerToken' from a product that is used for the good to be sold
     * @return bool Returns true if the product token is successfully removed, false otherwise
     */
    function removeUsedProduct(uint64 _tokenID, uint64 _productTokenID) public returns(bool) {
        require(ownerOf(_tokenID) == msg.sender, "You are not the owner of this token!");
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
     * @dev Retrieves the list of used product tokens and their usage percentages associated with a specific 'SellerToken' (_tokenID)
     *      This is used to understand how different product tokens ('BuyerTokens') contribute to the good sold represented by the 'SellerToken'
     * @param _tokenID The ID of the 'SellerToken' for which used products are being queried
     * @return uint256[] An array of token IDs of the used products
     * @return uint8[] An array of the usage percentages corresponding to each used product token
     */
    function getUsedProducts(uint64 _tokenID) public view returns(uint64[] memory, uint8[] memory) {
        uint64[] memory tokenIDs = new uint64[](UsedProducts[_tokenID].length);
        uint8[] memory percentages = new uint8[](UsedProducts[_tokenID].length);
        for (uint24 i = 0; i < UsedProducts[_tokenID].length; i++) {
            uint64 a = UsedProducts[_tokenID][i].TokenID;
            uint8 b = UsedProducts[_tokenID][i].UsagePercentage;
            tokenIDs[i] = a;
            percentages[i] = b;
        }
    return (tokenIDs, percentages);
    }

    /**
     * @dev Change the refund status in the data of the token to prevent double refundings
     * @param _tokenID The ID of the 'SellerToken' to prove that the good has not been consumed but processed and sold
     */
    //MODIFIER MUST BE ADDED IN THE FUTURE
    function changeRefundStatus(uint64 _tokenID) public onlyOwner {
        NFTData[_tokenID].isRefunded = true;
    }

    //MODIFIER MUST BE ADDED IN THE FUTURE
    function changeCurrentCountry(uint64 _tokenID, string memory _country) external onlyOwner {
        NFTData[_tokenID].current_country = _country;
    }

    /**
     * @dev The government (OnlyOwner) can devine a VAT-rate for each country (presumption of only 1 unified rate per country)
     * @param _country The country to set the VAT-rate for
     * @param VATRate The VAT-rate to be defined by the government according to the law
     */
    function setVatRate(string memory _country, uint16 VATRate) public onlyOwner {
        VATRates[_country] = VATRate;
    }

    /**
     * @dev The government (OnlyOwner) can delete wrong or outdated VAT-rates
     * @param _country The country to delete the VAT-rate for
     */
    function deleteVATRate(string memory _country) public onlyOwner {
        delete VATRates[_country];
    }

    /**
     * @dev Companies can be registered by the government (onlyOwner) and are stored in the Companies mapping
     * @param _address Address of the company to be registered
     * @param _name Name of the company
     * @param _UID The unique identifier of the company
     */
    function RegisterCompany(address _address, string memory _name, string memory _UID) public onlyOwner {
        require(!Companies[_address].isRegistered, "This company is already registered!");
        Company memory newCompany = Company(true, _name, _UID);
        Companies[_address] = newCompany;
    }

    /**
     * @dev Companies can be deleted by the government (onlyOwner) if they are registered
     * @param _address Address of the company to be deleted
     */
    function DeleteCompany(address _address) public onlyOwner {
        require(Companies[_address].isRegistered, "This company is not registered!");
        delete Companies[_address];
    }

    /**
     * @dev Companies can change their name via the government (onlyOwner) and the new name is updated into the mapping
     * @param _address Address of the company that changes its name
     * @param _name Name of the company to be changed
     */
    function ChangeCompanyName(address _address, string memory _name) public onlyOwner {
        require(Companies[_address].isRegistered, "This company is not registered!");
        Companies[_address].name = _name;
    }

    /**
     * @dev Companies can change their UID via the government (onlyOwner) and the new UID is stored in the mapping
     * @param _address Address of a company that changes its UID
     * @param _UID The unique identifier of the company to be changed
     */
    function ChangeCompanyUID(address _address, string memory _UID) public onlyOwner {
        require(Companies[_address].isRegistered, "This company is not registered!");
        Companies[_address].name = _UID;
    }

    /**
     * @dev Mints a new token according to the ERC721 standard and assigns it to a specified address. This method includes safety checks 
     *      to prevent common pitfalls in minting. The token ID is automatically set and the function increments the token ID counter 
     *      for each new token.
     * @param to The address to which the newly minted token will be assigned
     * @return uint256 The token ID of the newly minted token
     */
    // helper function, will be private in future
    function safeMint(address to) public returns(uint64) {
        uint64 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        return tokenId;
    }

    /**
     * @dev Creates receipt tokens for a transaction involving a buyer and a seller. This function mints two tokens:
     *      one representing the seller's side of the transaction and another for the buyer's side ('SellerToken and BuyerToken').
     *      The function checks that neither the buyer nor the seller is locked. The VAT is calculated and has to be paid before 
     *      the tokens can be minted. Therefore VAT-fraud can be prevented
     * @param _buyer The Adress of the buyer in the transaction
     * @param _seller The Adress of the seller in the transaction
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
        ) public onlyCompanies {
        uint40 _VAT_amount = _total_price * VATRates[_country_of_sale] / 1000;

        if (bytes(currency[_country_of_sale]).length == 0) {
            emit CurrencyNotRegistered(_country_of_sale);
            revert("The currency of this country has not been registered yet!");
        } 

        bool x;

        if (keccak256(abi.encodePacked(_country_of_sale)) == keccak256(abi.encodePacked("Switzerland"))) {
            x = VAT_CH_Contract.payTaxes(msg.sender, _VAT_amount);
        } else if (keccak256(abi.encodePacked(_country_of_sale)) == keccak256(abi.encodePacked("Germany"))) {
            x = VAT_DE_Contract.payTaxes(msg.sender, _VAT_amount);
        } else {
            revert("The country is not part of the system!");
        }

        require(x, "To create the ReceiptToken you have to pay the VAT!");
        require(lockedAddresses[msg.sender] != true, "The seller is locked and you can't create ReceiptTokens!");
        require(lockedAddresses[_buyerAddr] != true, "The buyer is locked and you can't create ReceiptTokens!");

        uint64 tokenID1 = safeMint(msg.sender);

        Receipt memory newReceipt1 = Receipt(
            "SellerToken",
            _buyer, 
            _seller, 
            _good,
            currency[_country_of_sale],
            _country_of_sale,
            _country_of_sale,  
            _quantity, 
            _total_price, 
            _VAT_amount,
            0,
            false
        );
        NFTData[tokenID1] = newReceipt1;

        uint64 tokenID2 = safeMint(_buyerAddr);

        Receipt memory newReceipt2 = Receipt(
            "BuyerToken",
            _buyer, 
            _seller, 
            _good, 
            currency[_country_of_sale],
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

        emit SellerTokenCreated(msg.sender, tokenID1);
        emit BuyerTokenCreated(_buyerAddr, tokenID2);
    }


    /**
     * @dev Creates receipt tokens for a transaction involving only a seller. This function mints one token:
     *      one representing the seller's side of the transaction and another for the buyer's side ('SellerToken and BuyerToken').
     *      The function checks that neither the buyer nor the seller is locked. The VAT is calculated and has to be paid before 
     *      the tokens can be minted. Therefore VAT-fraud can be prevented
     * @param _buyer The Adress of the buyer in the transaction
     * @param _seller The Adress of the seller in the transaction
     * @param _good The description of the good or service being transacted
     * @param _country_of_sale The country in which the sale takes place
     * @param _quantity The quantity of the good being transacted
     * @param _total_price The total price of the transaction
     */
    function createReceiptSellerToken(
        string memory _buyer,
        string memory _seller,
        string memory _good,
        string memory _country_of_sale,
        uint32 _quantity,
        uint40 _total_price
        ) public onlyCompanies {
        uint40 _VAT_amount = _total_price * VATRates[_country_of_sale] / 1000;

        if (bytes(currency[_country_of_sale]).length == 0) {
            emit CurrencyNotRegistered(_country_of_sale);
            revert("The currency of this country has not been registered yet!");
        }

        bool x;
        if (keccak256(abi.encodePacked(_country_of_sale)) == keccak256(abi.encodePacked("Switzerland"))) {
            x = VAT_CH_Contract.payTaxes(msg.sender, _VAT_amount);
        } else if (keccak256(abi.encodePacked(_country_of_sale)) == keccak256(abi.encodePacked("Germany"))) {
            x = VAT_DE_Contract.payTaxes(msg.sender, _VAT_amount);
        } else {
            revert("The country is not part of the system!");
        }

        
        require(x, "To create the ReceiptToken you have to pay the VAT!");
        require(lockedAddresses[msg.sender] != true, "The seller is locked and you can't create ReceiptTokens!");

        uint64 tokenID1 = safeMint(msg.sender);

        Receipt memory newReceipt1 = Receipt(
            "SellerToken",
            _buyer, 
            _seller, 
            _good, 
            currency[_country_of_sale],
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
        emit EndOfChain(tokenID1);
    }
}