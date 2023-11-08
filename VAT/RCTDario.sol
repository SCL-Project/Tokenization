// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC721, ERC721Burnable, Ownable {
    uint256 private _nextTokenId;

    constructor(address initialOwner)
        ERC721("MyToken", "MTK")
        Ownable(initialOwner)
    {}

    //----------------------------Structs-------------------------------

    struct Receipt {
        string buyer;
        string seller;
        string good;
        string country_of_sale;
        string VATEUR_payment_transaction_hash;
        uint256 amount;
        uint256 total_price;
        uint256 VAT_amount;
    }

    struct Company {
        bool isRegistered;
        string name;
        string UID;
    }


    //----------------------------Mappings-------------------------------

    mapping (uint256 => Receipt) public NFTData;

    mapping (address => Company) public Companies;


    //----------------------------Modifier-------------------------------

    modifier onlyCompanies() {

        // checking that the struct is initialized (not the default value)
        // Either the caller is a registered company or the owner himself.
        require(Companies[msg.sender].isRegistered || msg.sender == Ownable.owner(), "Only registered Companies can call this Function!");
        _;
    }


    //----------------------------Functions-------------------------------

    function RegisterCompany(address _address, string memory _name, string memory _UID) public onlyOwner {
        require(!Companies[_address].isRegistered, "This company is already registered!");
        Company memory newCompany = Company(true, _name, _UID);
        Companies[_address] = newCompany;
    }

    function DeleteCompany(address _address) public onlyOwner {
        delete Companies[_address];
    }

    function ChangeCompanyName(address _address, string memory _name) public onlyOwner {
        require(Companies[_address].isRegistered, "This company is not registered!");
        Companies[_address].name = _name;
    }

    function ChangeCompanyUID(address _address, string memory _UID) public onlyOwner {
        require(Companies[_address].isRegistered, "This company is not registered!");
        Companies[_address].name = _UID;
    }



    function safeMint(address to) public onlyOwner returns(uint256) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        return tokenId;
    }

    function createReceiptToken(

        string memory _buyer,
        string memory _seller,
        string memory _good,
        string memory _country_of_sale,
        string memory _VATEUR_payment_transaction_hash,
        uint256 _amount,
        uint256 _total_price,
        uint256 _VAT_amount

        ) public onlyCompanies {

        uint256 tokenId = safeMint(msg.sender);

        Receipt memory newReceipt = Receipt(
            _buyer, 
            _seller, 
            _good, 
            _country_of_sale, 
            _VATEUR_payment_transaction_hash, 
            _amount, 
            _total_price, 
            _VAT_amount);
        NFTData[tokenId] = newReceipt;
    }
}