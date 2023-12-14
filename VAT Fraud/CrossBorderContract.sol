// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./VATToken_DE.sol";
import "./VATToken_CH.sol";
import "./RCT.sol";

/// @title CrossBorderContract
/// @author Samuel Clauss & Dario Ganz
contract CrossBorderContract {
    ReceiptTokenContract public RCTContract;
    VATToken_CH public VAT_CH_Contract;
    VATToken_DE public VAT_DE_Contract;    
    address[] private owners;

    /**
     * @dev Constructor to initialize the contract of the CrossBorder
     * @param _owners The address that will be granted the ownership of the contract
     *        In our case the government will have the access.
     */
    constructor(address[] memory _owners, address _RCTAddress, address VAT_CH_Address, address VAT_DE_Address) {
        for (uint24 i = 0; i < _owners.length; i++) {
            isOwner[_owners[i]] = true;
            owners.push(_owners[i]);
        }
        RCTContract = ReceiptTokenContract(_RCTAddress);
        VAT_CH_Contract = VATToken_CH(VAT_CH_Address);
        VAT_DE_Contract = VATToken_DE(VAT_DE_Address);
    }

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

    //----------------------------Events---------------------------------

    event CrossedBorder(string from, string to, uint64 tokenID);

    //----------------------------Mappings-------------------------------

    /**
     * @dev Mapping to store VAT-rates associated with the respective country
     */
    mapping (string => uint16) public VATRates; 

    // Mapping of owner addresses to their status (true if owner)
    mapping(address => bool) private isOwner;

    mapping(string => bool) public ForbiddenGoods;


    //----------------------------Modifier-------------------------------

    /**
     * @dev Modifier to allow only registered and unlocked companies.
     */
    modifier onlyRegisteredAndUnlockedCompanies() {
        bool isRegistered;
        (isRegistered,,) = RCTContract.getCompany(msg.sender);
        require(isRegistered, "Company not registered");
        require(!RCTContract.isCompanyLocked(msg.sender), "Company is locked");
        _;
    }

    // Modifier to check if the caller is an owner
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Caller is not an owner");
        _;
    }

    //----------------------------Functions-------------------------------

    function addForbiddenGoods(string memory good) public onlyOwner {
        ForbiddenGoods[good] = true;
    }

    // Function to remove an owner, only callable by an existing owner
    function removeForbiddenGoods(string memory good) public onlyOwner {
        ForbiddenGoods[good] = false;
    }

    // Function to add a new owner, only callable by an existing owner
    function addOwner(address _newOwner) public onlyOwner {
        isOwner[_newOwner] = true;
    }

    // Function to remove an owner, only callable by an existing owner
    function removeOwner(address _owner) public onlyOwner {
        isOwner[_owner] = false;
    }

    function getOwners() public onlyOwner view returns(address[] memory) {
        return owners;
    }

    /**
     * @dev The government (onlyOwner) can devine a VAT-rate for each country (presumption of only 1 unified rate per country)
     * @param _country The country to set the VAT-rate for
     * @param _rate The VAT-rate to be defined by the governments according to the national law
     */
    function addVATRate(string memory _country, uint16 _rate) public onlyOwner {
        VATRates[_country] = _rate;
    }

    /**
     * @dev The government (OnlyOwner) can delete wrong or outdated VAT-rates
     * @param _country The country to delete the VAT-rate for
     */
    function deleteVATRate(string memory _country) public onlyOwner {
        delete VATRates[_country];
    }

    /**
     * @dev Sets the address of the VATTokenContract
     * @param _address The address of the VATTokenContract
     */
    function setVATTokenAddress(address _address) public onlyOwner {
        VATTokenContractAddress = _address;
        VATTokenIsSet = true;
    }

    /**
     * @dev Sets the address of the ReceiptTokenContract
     * @param _address The address of the ReceiptTokenContract
     */
    function setRCTAddress(address _address) public onlyOwner {
        RCTContractAddress = _address;
        RCTAddressIsSet = true;
    }

    /**
     * @dev Handles the cross-border transfer of a product represented by a ReceiptToken. 
     *      It calculates and settles the tax differences based on VAT-rates of the countries involved. 
     *      The function ensures that the caller is the owner of the token and that the token represents 
     *      a product that can be legally exported. The function makes sure that the product is in the 
     *      same country as it's exported from andhas not already been soldIt adjusts the VAT-payments 
     *      according to the VAT-rate of the destination country
     * @param _tokenID The ID of the token representing the product being exported
     * @param _from The country from which the product is being exported
     * @param _to The country to which the product is being exported
     */
    function CrossBorder(uint64 _tokenID, string memory _from, string memory _to) external onlyRegisteredAndUnlockedCompanies {
        string memory Type = RCTContract.getNFTData(_tokenID).Type;
        string memory Country = RCTContract.getNFTData(_tokenID).country_of_sale;
        string memory good = RCTContract.getNFTData(_tokenID).good;
        uint40 VAT_amount = RCTContract.getNFTData(_tokenID).VAT_amount;
        uint40 price = RCTContract.getNFTData(_tokenID).total_price;




        require(VATTokenIsSet, "The VATToken Contract Address is not yet set!");
        require(RCTAddressIsSet, "The RCT Contract Address is not yet set!");
        require(RCTContract.ownerOf(_tokenID) == msg.sender, "You are not the owner of this token!");
        require(keccak256(abi.encodePacked(Country)) == keccak256(abi.encodePacked(_from)), "The product must be in the same country you want to export from!");
        require(VATRates[_from] != 0, "The country you want to export your product from is not known!");
        require(VATRates[_to] != 0, "The country you want to export your product to is not known!");
        require(keccak256(abi.encodePacked(Type)) == keccak256(abi.encodePacked("BuyerToken")), "You can't export a product you have already sold!");
        require(!ForbiddenGoods[good], "It is forbidden to export or import this good!");

        uint40 taxes_payable = price * VATRates[_to] / 1000;
        uint40 difference = VAT_amount - taxes_payable;

        bool TaxesPaid = true;

        if (difference > 0 && price > 300) {
            VATTokenContract.transferGovernment(msg.sender, difference);
        } else if (difference < 0 && price > 300) {
            TaxesPaid = VATTokenContract.payTaxes(msg.sender, difference);
        }
        assert(TaxesPaid); 
        RCTContract.changeCurrentCountry(_tokenID, _to);

        emit CrossedBorder(_from, _to, _tokenID);
    }
}
