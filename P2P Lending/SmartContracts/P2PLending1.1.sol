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

//-----------------------------------------------Interface---------------------------------------------------

interface IERC20 {
    /**
     * @dev Transfers tokens from one address to another
     * @param sender The address from which the tokens will be debited
     * @param recipient The address to which the tokens will be credited
     * @param amount The number of tokens to transfer
     * @return bool indicating whether the operation was successful
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

//-------------------------------------------P2PLendingContract----------------------------------------------

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

//---------------------------------------------HelperFunction------------------------------------------------

    /**
     * @dev Sets the address of the stablecoin contract to choose with which one the transfer takes place.
     *      Can only be called by the contract owner
     * @param _stablecoinAddress The address of the ERC-20 stablecoin contract
     */
    function setStablecoinAddress(address _stablecoinAddress) external onlyOwner {
        stablecoinAddress = _stablecoinAddress;
    }

//------------------------------------------------Structs-----------------------------------------------------

    /**
    * @dev Struct to store the details of the lending contract represented as NFTs
    * @param Type A string indicating the type of the token (e.g., "LenderToken" or "BorrowerToken")
    * @param Lender The wallet address of the lender giving the credit
    * @param Borrower The wallet address of the borrower receiving the credit
    * @param Amount The amount of the loan
    * @param InterestRate The interest rate applied to the loan, represented as a whole number (e.g., 5 for 5%)
    * @param PayBackAmount The total amount to be repaid by the borrower, including interest
    * @param IsRefunded A boolean indicating whether the loan has been repaid or not
    * @param TwinTokenID The token ID of the corresponding twin token (e.g., the Lender's token ID if this is the Borrower's token, and vice versa)
    */
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

    /**
    * @dev Struct to store all registered addresses of registered users on the P2PLending Website
    * @param Bool A boolean to check whether an address is registered or not
    */
    struct RegisteredAdresses {
        bool isRegistered;
    }

    //------------------------------------------------Mappings----------------------------------------------------

    /**
     * @dev Mapping to store data of Receipt associated with a tokenID
     */
    mapping (uint256 => Contract) private ContractData;

    /**
     * @dev Mapping to store user data associated with an address and no sensible private data
     */
    mapping (address => RegisteredAdresses) private Registry;

    //------------------------------------------------Events------------------------------------------------------
    
    /** @dev Emitted when a new credit has been granted from a lender
     *  @param Lender The wallet address of the lender of the credit
     *  @param Borrower The wallet address of the borrower
     *  @param Amount The amount borrowed
    */
    event CreditGranted(address Lender, address Borrower, uint256 Amount);

    /** @dev Emitted when a new credit has been repaid by a borrower
     *  @param Borrower The wallet address of the lender of the credit
     *  @param payBackAmount The amount borrowed
    */
    event LoanRepaid(address indexed Borrower, uint256 payBackAmount);

    //------------------------------------------------Modifier----------------------------------------------------

    /**
     * @dev Ensures that the function can only be called by registered users
     */
    modifier onlyRegisteredUsers() {
        require(Registry[msg.sender].isRegistered, "Only registered Users grant or receive a loan");
        _;
    }

    //--------------------------------------------HelperFunctions-------------------------------------------------

    /**
     * @dev Retrieves the contract data for a given token ID
     * @param _tokenId The token ID for which contract data is being retrieved
     * @return A `Contract` struct containing details of the loan associated with the provided token ID
     */
    function getContractData(uint56 _tokenId) public view onlyOwner returns(Contract memory) {
        return ContractData[_tokenId];
    }

    /**
     * @dev Checks if a given address is registered as a user
     * @param _address The address to check for registration
     * @return 'true' if the address is registered and 'false' if not
     */
    function getUser(address _address) public view onlyOwner returns(bool) {
        return (Registry[_address].isRegistered);
    }

    //-----------------------------------------------Functions----------------------------------------------------

    /**
    * @dev Registers a new user address. Can only be called by the contract owner
    * @param _address The address to be registered
    */
    function RegisterUser(address _address) external onlyOwner {
        require(!Registry[_address].isRegistered, "Company already registered");
        RegisteredAdresses memory newUser = RegisteredAdresses(true);
        Registry[_address] = newUser;
    }

    /**
    * @dev Deletes a user address from the registry. Can only be called by the contract owner
    * @param _address The address to be deleted
    */
    function DeleteUser(address _address) external onlyOwner {
        require(Registry[_address].isRegistered, "User already registered");
        delete Registry[_address];
    }

    /**
    * @dev Safely mints a new NFT and assigns it to a user. Can only be called by registered users
    * @param to The address of the recipient for the newly minted token
    * @return The token ID of the newly minted token
    */
    function safeMint(address to) public onlyRegisteredUsers returns(uint56) {
        uint56 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        return tokenId;
    }

    /**
    * @dev Executes a new loan contract between a lender and a borrower, minting two linked NFTs 
    *      representing the contract details
    * @param _Lender The address of the lender
    * @param _Borrower The address of the borrower
    * @param _Amount The amount of the loan
    * @param _InterestRate The interest rate of the loan
    * @param _StablecoinAmount The stablecoin amount to be transferred from the lender to the borrower
    */
    function ContractExecution(
        address _Lender,
        address _Borrower,
        uint256 _Amount,
        uint256 _InterestRate,
        uint256 _StablecoinAmount
        ) external onlyRegisteredUsers {
        require(Registry[_Lender].isRegistered && Registry[_Borrower].isRegistered);
        require(IERC20(stablecoinAddress).transferFrom(_Lender, _Borrower, _StablecoinAmount), 
        "Stablecoin transfer failed");
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

        /**
     * @dev Allows a borrower to repay their loan. This also triggers the updating both
     *      the Lender and BorrowerToken to mark the loan as repayed
     * @param _tokenID The ID of the borrower's NFT representing the loan
     */
    function payback(uint56 _tokenID) external onlyRegisteredUsers {
        Contract storage contractDetails = ContractData[_tokenID];
        require(msg.sender == contractDetails.Borrower, "Only the borrower can repay");
        require(!contractDetails.IsRefunded, "Loan already repaid");
        require(IERC20(stablecoinAddress).transferFrom(msg.sender, contractDetails.Lender, contractDetails.PayBackAmount),"Payback failed");
        contractDetails.IsRefunded = true;
        ContractData[contractDetails.TwinTokenID].IsRefunded = true;
        emit LoanRepaid(msg.sender, contractDetails.PayBackAmount);
    }
}