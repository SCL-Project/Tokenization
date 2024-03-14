// ***************************************************************************************************************
// SPDX-License-Identifier: MIT
/// @title P2PLending Contract
/// @author Dario Ganz
// Smart Contracts Lab, University of Zurich
// Created: February 16, 2024
// ***************************************************************************************************************
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract P2PLending is ERC721, ERC721Burnable, Ownable {
    uint56 private _nextTokenId = 1;
    address initialOwner;
    address public stablecoinAddress;

    /**
     * @dev Constructor to initialize the P2PLending Contract
     * @param _initialOwner Address of the owner
     */
    constructor(address _initialOwner) 
            ERC721("P2PLending", "P2P")
            Ownable(_initialOwner)
        {
            initialOwner = _initialOwner;
        }
    
    /**
     * @dev Setzt die Adresse des Stablecoin Contracts.
     * Kann nur vom Owner des Contracts aufgerufen werden.
     * @param _stablecoinAddress Die Adresse des Stablecoin ERC-20 Contracts.
     */
    function setStablecoinAddress(address _stablecoinAddress) external onlyOwner {
        stablecoinAddress = _stablecoinAddress;
    }

    //------------------------------------------------Structs-----------------------------------------------------

    struct Contract {
        string Type;
        address Lender;
        address Borrower;
        uint256 Amount;
        uint256 InterestRate;
        uint256 PayBackAmount;
        bool IsRefunded;
        uint256 TwinTokenID;
    }

    struct RegisteredAdresses {
        bool isRegistered;
    }

    //------------------------------------------------Mappings----------------------------------------------------

    /**
     * @dev Mapping to store data of Receipt associated with a tokenID
     */
    mapping (uint256 => Contract) private ContractData;

    /**
     * @dev Mapping to store company data associated with an address
     */
    mapping (address => RegisteredAdresses) private Registry;

    //------------------------------------------------Events------------------------------------------------------
    
    event CreditGranted(address Lender, address Borrower, uint256 Amount);

    //------------------------------------------------Modifier----------------------------------------------------

    /**
     * @dev Ensures that the function can only be called by registered users
     */
    modifier onlyRegisteredUsers() {
        require(Registry[msg.sender].isRegistered, "Only registered Users grant or receive a loan");
        _;
    }

    //--------------------------------------------HelperFunctions-------------------------------------------------

    function getContractData(uint56 _tokenId) public view returns(Contract memory) {
        return ContractData[_tokenId];
    }

    function getUser(address _address) public view returns(bool) {
        return (Registry[_address].isRegistered);
    }

    //-----------------------------------------------Functions----------------------------------------------------

    function changeRefundStatus(uint56 _tokenID) onlyRegisteredUsers external {
        ContractData[_tokenID].IsRefunded = true;
    }

    function RegisterUser(address _address) external onlyOwner {
        require(!Registry[_address].isRegistered, "Company already registered");
        RegisteredAdresses memory newUser = RegisteredAdresses(true);
        Registry[_address] = newUser;
    }

    function DeleteUser(address _address) external onlyOwner {
        require(Registry[_address].isRegistered, "User already registered");
        delete Registry[_address];
    }

    function safeMint(address to) public onlyRegisteredUsers returns(uint56) {
        uint56 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        return tokenId;
    }

    function ContractExecution(
        address _Lender,
        address _Borrower,
        uint256 _Amount,
        uint256 _InterestRate,
        uint256 _StablecoinAmount
        ) external onlyRegisteredUsers {
        require(IERC20(stablecoinAddress).transferFrom(_Lender, _Borrower, _StablecoinAmount), "Stablecoin transfer failed");
        uint256 _PayBackAmount = _Amount * (1+_InterestRate);
        uint256 tokenID1 = this.safeMint(msg.sender);

        Contract memory LenderContract = Contract(
            "LenderToken",
            _Lender, 
            _Borrower, 
            _Amount,
            _InterestRate,
            _PayBackAmount,
            false,  
            0
        );
        ContractData[tokenID1] = LenderContract;

        uint56 tokenID2 = this.safeMint(_Borrower);

        Contract memory BorrowerContract = Contract(
            "BorrowerToken",
            _Lender, 
            _Borrower, 
            _Amount,
            _InterestRate,
            _PayBackAmount,
            false,
            tokenID1
            );
            ContractData[tokenID2] = BorrowerContract;
            ContractData[tokenID1].TwinTokenID = tokenID2;

        emit CreditGranted(_Lender, _Borrower, _Amount);
        }
}