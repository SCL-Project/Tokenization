// ***************************************************************************************************************
// SPDX-License-Identifier: MIT
// @title CrossBorderContract
// @authors Samuel Clauss & Dario Ganz
// Smart Contracts Lab, University of Zurich
// Created: December 20, 2023
// ***************************************************************************************************************
// Read the Whitepaper https://github.com/SCL-Project/Tokenization/blob/main/Whitepaper.md
// ***************************************************************************************************************
pragma solidity ^0.8.20;

import "./Oracle.sol";
import "./ReceiptTokenContract.sol";
import "./VATToken_DE.sol";
import "./VATToken_CH.sol";

contract CrossBorderContract {
    ReceiptTokenContract public RCTContract;
    VATToken_CH public VAT_CH_Contract;
    VATToken_DE public VAT_DE_Contract;  
    Oracle public OracleContract = Oracle(0xE0A74b0171615099B3aeef9456eFcE181aF9aE8E);  
    address[] private owners;

    /**
     * @dev Constructor to initialize the CrossBorderContract
     Sets the initial owners of the contract and initializes contracts for VAT tokens and receipt tokens
     * @param _RCTAddress The address of the ReceiptTokenContract, which manages receipt tokens
     * @param VAT_CH_Address The address of the VATToken contract for Switzerland (CH)
     * @param VAT_DE_Address The address of the VATToken contract for Germany (DE)
     */
    constructor(address _initialOwner, address _RCTAddress, address VAT_CH_Address, address VAT_DE_Address) {
        owners = [_initialOwner, _RCTAddress, VAT_CH_Address, VAT_DE_Address];
        for (uint24 i = 0; i < owners.length; i++) {
            isOwner[owners[i]] = true;
        }
        RCTContract = ReceiptTokenContract(_RCTAddress);
        VAT_CH_Contract = VATToken_CH(VAT_CH_Address);
        VAT_DE_Contract = VATToken_DE(VAT_DE_Address);
    }

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

    //------------------------------------------------Events------------------------------------------------------

    /**  
     * @dev Emitted when an item crosses international borders. Logs the details of border crossing events
     * @param from The country from which the item is being sent
     * @param to The country to which the item is being sent
     * @param tokenID The unique identifier of the item
     */
    event CrossedBorder(string from, string to, uint56 tokenID);

    //------------------------------------------------Mappings----------------------------------------------------

    /**
     * @dev Indicates whether an address is an owner or not (true or false). This mapping is used for
     *      access control, restricting certain operations to owners only
     */ 
    mapping(address => bool) private isOwner;

    /**
     * @dev Keeps track of goods that are forbidden or allowed (true or false). This public mapping allows
     *       for checking the status of goods (useful for compliance and logistics)
     */
    mapping(string => bool) public ForbiddenGoods;

    //------------------------------------------------Modifier---------------------------------------------------

    /**
     * @dev Modifier to allow only registered companies
     */
    modifier onlyRegisteredCompanies() {
        bool isRegistered;
        (isRegistered,,) = RCTContract.getCompany(msg.sender);
        require(isRegistered, "Company not registered");
        _;
    }

    /**
     * @dev Modifier to check if the caller is an owner
     */
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Caller is not an owner");
        _;
    }

    //---------------------------------------------Helperfunctions-----------------------------------------------

    /**
     * @dev Adds a good to the list of forbidden goods. Modifies the `ForbiddenGoods` mapping by setting 
     *      the value for the provided good to `true`. Only callable by an existing owner
     * @param good The name of the good marked as forbidden
     */
    function addForbiddenGoods(string memory good) external onlyOwner {
        ForbiddenGoods[good] = true;
    }

    /**
     * @dev Removes a good from the list of forbidden goods. Modifies the `ForbiddenGoods` mapping by setting
     *      the value for the provided good to `false`. Only callable by an existing owner
     * @param good The name of the good marked as allowed
     */
    function removeForbiddenGoods(string memory good) external onlyOwner {
        ForbiddenGoods[good] = false;
    }

    /**
     * @dev Adds a new owner to the contract. Modifies the `isOwner` mapping by setting the value for the provided
     *      address to `true`. Only callable by an existing owner
     * @param _newOwner The address to be added as a new owner
     */
    function addOwner(address _newOwner) external onlyOwner {
        isOwner[_newOwner] = true;
    }

    /**
     * @dev Removes an existing owner from the contract. Modifies the `isOwner` mapping by setting the value 
     *      for the provided address to `false`. Only callable by an existing owner
     * @param _owner The address of the owner to be removed
     */
    function removeOwner(address _owner) external onlyOwner {
        isOwner[_owner] = false;
    }

    /**
     * @dev Returns a list of all owner addresses. Provides read access to private `owners` array
     * @return owners array of addresses representing the current owners
     */
    function getOwners() public onlyOwner view returns(address[] memory) {
        return owners;
    }


//------------------------------------------------Functions--------------------------------------------------

    /**
     * @dev Handles the cross-border transfer of a good represented by a ReceiptToken. 
     *      It calculates and settles the tax differences based on VAT rates of the countries involved. 
     *      The function ensures that the caller is a registered company, the owner of the token and 
     *      that the token represents a good that can be legally exported. The function makes sure that
     *      the good is in the same country as it's exported from and has not already been sold. It adjusts 
     *      the VAT payments according to the VAT rate of the destination country if the price is higher than
     *      300 CHF or EUR. If the price is lower than 300 just the current country of the good is exchanged
     * @param _tokenID The ID of the token representing the good being exported
     * @param _to The country to which the good is being exported
     */
    function CrossBorder(uint56 _tokenID, string memory _to) external onlyRegisteredCompanies {
        string memory Type = RCTContract.getNFTData(_tokenID).Type;
        string memory Country = RCTContract.getNFTData(_tokenID).country_of_sale;
        string memory good = RCTContract.getNFTData(_tokenID).good;
        uint40 VAT_amount = RCTContract.getNFTData(_tokenID).VAT_amount;
        uint40 price = RCTContract.getNFTData(_tokenID).total_price;

        require(RCTContract.ownerOf(_tokenID) == msg.sender, "You are not the owner of this token!");
        require(OracleContract.getVATRate(_to) != 0, 
        "The country you want to export your product to is not known!");
        require(keccak256(abi.encodePacked(Type)) == keccak256(abi.encodePacked("BuyerToken")), 
        "You can't export a product you have already sold!");
        require(!ForbiddenGoods[good], "It is forbidden to export or import this good!");

        uint40 taxes_payable = price * OracleContract.getVATRate(_to) / 1000;
        int40 temp = int40(VAT_amount) - int40(taxes_payable);
        uint40 difference;

        if (temp > 0) {
            difference = uint40(temp);
        } else {
            difference = uint40(-temp);
        }

        bool TaxesPaid = true;

        // Exporting to Germany
        if (keccak256(abi.encodePacked(Country)) == keccak256(abi.encodePacked("Switzerland")) &&
        price > 300) {
            TaxesPaid = VAT_CH_Contract.payTaxes(msg.sender, difference);
            assert(TaxesPaid);
            VAT_CH_Contract.transferGovernment(address(VAT_DE_Contract), taxes_payable * 100);

        // Exporting to Switzerland
        } else if (keccak256(abi.encodePacked(Country)) == keccak256(abi.encodePacked("Germany")) &&
        price > 300) {
            VAT_DE_Contract.transferGovernment(address(VAT_CH_Contract), taxes_payable * 100);
            VAT_DE_Contract.transferGovernment(msg.sender, difference * 100);
        }
        RCTContract.changeCurrentCountry(_tokenID, _to);
        emit CrossedBorder(Country, _to, _tokenID);
    }

    /**
     * @dev Determines if a token has crossed borders by comparing the country of sale and the current 
     *      country of the token. It returns true if the token has crossed borders (i.e., the countries
     *      are different) and false otherwise. This function can only be called by the contract owner
     * @param _tokenID The ID of the token to check for the border crossing
     * @return bool Returns true if the token has crossed borders, false if it has not
     */
    function wasBorderCrossed(uint56 _tokenID) external onlyOwner view returns(bool){
        string memory CountryOfSale = RCTContract.getNFTData(_tokenID).country_of_sale;
        string memory CurrentCountry = RCTContract.getNFTData(_tokenID).current_country;

        if (keccak256(abi.encodePacked(CountryOfSale)) == keccak256(abi.encodePacked(CurrentCountry))) {
            return false;
        }   else {
            return true;
        }
    }
}
