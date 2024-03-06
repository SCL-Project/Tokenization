// ***************************************************************************************************************
// SPDX-License-Identifier: MIT
// @title VATTokenContract Germany
// @authors Samuel Clauss & Dario Ganz
// Smart Contracts Lab, University of Zurich
// Created: December 20, 2023
// ***************************************************************************************************************
// Read the Whitepaper https://github.com/SCL-Project/Tokenization/blob/main/Whitepaper.md
// ***************************************************************************************************************
pragma solidity ^0.8.20;

import "./VATToken_CH.sol";
import "./Oracle.sol";
import "./ReceiptTokenContract.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract VATToken_DE is ERC20, ERC20Burnable, Ownable, ERC20Permit {
    address CrossBorderContract;
    address initialOwner;
    address private RCTAddress;
    ReceiptTokenContract public RCTContract;
    VATToken_CH public VATToken_CH_Contract;
    Oracle public OracleContract = Oracle(0xE0A74b0171615099B3aeef9456eFcE181aF9aE8E);

    /**
     * @dev Constructor to initialize the VATToken coontract of Germany. Sets the initialOwner of the contract
     *      and initializes the address of the ReceiptTokenContract
     * @param _initialOwner The address to be granted ownership of the contract -> the German tax authority
     * @param _RCTAddress The address of the ReceiptTokenContract
     */
    constructor(address _initialOwner, address _RCTAddress)
        ERC20("VAT_GER", "VDE")
        Ownable(_initialOwner)
        ERC20Permit("VATToken")
    {
        RCTContract = ReceiptTokenContract(_RCTAddress);
        RCTAddress = _RCTAddress;
        initialOwner = _initialOwner;
    }

    function decimals() public pure override returns (uint8) {
        return 2;
    }

    //------------------------------------------------Structs------------------------------------------------------

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

    //-------------------------------------------------Events-----------------------------------------------------

    /**  
     * @dev Emitted when a company gets a 'TokenCredit' or additional 'TokenCredit'
     * @param company The company that accesses the function
     * @param amount The amount of 'TokenCredit' given
     */
    event TokenCreditReceived(address company, uint256 amount);

    /**  
     * @dev Emitted when a company withdraws VATTokens from their 'TokenCredit'
     * @param company The company that accesses the function
     * @param amount The amount to withdraw from the 'TokenCredit'
     */
    event TokensBought(address company, uint256 amount);

    /**  
     * @dev Emitted when a company sells VATToken from their token balance back to the government
     * @param company The company that accesses the function
     * @param amount The amount to sold from the token balance
     */
    event PaymentToBeReleased(address company, uint256 amount, string otherInformation);

    //-----------------------------------------------Mappings----------------------------------------------------

    /**
     * @dev Mapping to store the amount of TokenCredit
     */
    mapping (address => uint256) private TokenCredit;

    //-----------------------------------------------Modifier----------------------------------------------------

    /**
     * @dev Ensures transfers are only allowed between specific addresses and not between companies
     * @param _from The address of the sender
     * @param _to The address of the receiver
     */
    modifier transferRestriction(address _from, address _to) {
        require(_from == address(this) || _from == CrossBorderContract || _to == address(this) || 
        _to == CrossBorderContract, "Transactions between companies are not allowed!");
        _;
    }

    /**
     * @dev Ensures that some functions can only be accessed by the government instances
     */
    modifier onlyGovernment() {
        require(msg.sender == initialOwner || msg.sender == address(this) || msg.sender == CrossBorderContract || 
        msg.sender == RCTAddress, "Only Government!");
        _;
    }

    //---------------------------------------------HelperFunctions-------------------------------------------------

    /**
     * @dev Returns the token credit amount of the caller. Provides a view function to check the 
     *      `TokenCredit` balance associated with the caller's address
     * @return The amount of token credit available for the calling address
     */
    function checkTokenCredit() external view returns(uint256) {
        return TokenCredit[msg.sender];
    }

    /**
     * @dev Checks if an address has a non-default token credit
     * @param _address The address that is checked
     * @return bool Returns true if the address has a non-default credit value
     */
    function checkIfKeyExists(address _address) internal view returns (bool) {
        return TokenCredit[_address] != 0;
    }

    /**
     * @dev Sets the address of the CrossBorderContract
     * @param _CBC_address The address of the CrossBorderContract
     * @param _VAT_CH_address, The address of the VATToken_CH Contract
     */
    function contractAddresses(address _CBC_address, address _VAT_CH_address) external onlyOwner {
        CrossBorderContract = _CBC_address;
        VATToken_CH_Contract = VATToken_CH(_VAT_CH_address);
    }

    /**
     * @dev Retrieves the address of the CrossBorderContract currently set in the system
     * @return address The address of the CrossBorderContract
     */
    function getCBCAddress() external view returns(address) {
        return CrossBorderContract;
    }

    //------------------------------------------------Funcitons-----------------------------------------------------

    /**
     * @dev Set or update the token credit for an address. Only callable by the government instances. The
     *      Tokencredit is set after the government received a fiat transaction from the corresponding company
     * @param _address The address to update
     * @param _amount The credit amount to set or add
     */
    function setTokenCredit(address _address, uint256 _amount) external onlyGovernment {
        if (checkIfKeyExists(_address)) {
            TokenCredit[_address] += _amount * 100;
        } else {
            TokenCredit[_address] = _amount * 100;
        }
        emit TokenCreditReceived(_address, _amount);
    } 

    /**
     * @dev Mints tokens to a specified address. Only callable by the government instances
     * @param to The address to which the tokens are minted to
     * @param amount The amount of tokens to be minted
     */
    function mint(address to, uint256 amount) public onlyGovernment {
        _mint(to, amount);
    }

    /**
     * @dev Transfers a specified amount of tokens from the contract to a specific address. 
     *      If the contract doesn't have enough tokens, the required amount gets minted.
     *      This function is restricted to government instances
     * @param _to The address to which the tokens will be transferred or minted
     * @param _amount The amount of tokens to be transferred or minted
     */
    function transferGovernment(address _to, uint40 _amount) public onlyGovernment {
        if (balanceOf(address(this)) >= _amount) {
            _transfer(address(this), _to, _amount);
        } else {
            mint(_to, _amount);
        }
    }

    /**
     * @dev Transfers a specified amount of tokens from the sender's address to another address. Additionally
     *      overrides the standard ERC20 transfer function with the transferRestriction modifier    
     * @param _to The address to transfer tokens to
     * @param value The amount of tokens to transfer
     * @return bool Returns true if the transfer is successful
     */
    function transfer(address _to, uint256 value) public override transferRestriction(msg.sender, _to) 
    returns(bool) {
    }

    /**
     * @dev Transfers a specified amount of tokens from one address to another, based on a prior allowance. 
     *      Unlike 'transfer', which moves tokens from the blance of the caller (msg.sender), transferFrom
     *      permits a third party, the government, with the necessary allowance to transfer tokens on behalf 
     *      of another address. It overrides the standard ERC20 transferFrom function with the 
     *      transferRestriction modifier
     * @param _from The address to transfer tokens from
     * @param _to The address to transfer tokens to
     * @param value The amount of tokens to transfer
     * @return bool Returns true if the transfer is successful
     */
     
    function transferFrom(address _from, address _to, uint256 value) public override transferRestriction(_from, _to) 
    returns(bool) {
    }

    /**
     * @dev Transfers a specified amount of tokens from a given address to the contract as VAT-payment.
     *      Only callable by accounts with the role of government entities
     * @param _from The address from which the tax amount will be substracted
     * @param _amount The amount of tokens to be paid
     * @return bool Returns true if the tax payment is successful, otherwise false
     */
    function payTaxes(address _from, uint40 _amount) public onlyGovernment returns(bool) {
        if (balanceOf(_from) >= _amount * 100) {
            _transfer(_from, address(this), _amount * 100);
            return true;
        }
        return false;
    }

    /**
     * @dev Refunds taxes for a specific tokenID by transferring the appropriate amount of VAT back to the owner
     *      of the ReceiptToken. The function calculates the refund amount based on the tax and percentages of used 
     *      products associated with the token. It supports refunds for tokens from Germany and Switzerland
     * @param _tokenID The ID of the token for which the tax refund is requested
     */
    function refundTaxes(uint56 _tokenID) external {
        require(
            keccak256(abi.encodePacked(RCTContract.getNFTData(_tokenID).current_country)) == keccak256(abi.encodePacked("Switzerland")) ||
            keccak256(abi.encodePacked(RCTContract.getNFTData(_tokenID).current_country)) == keccak256(abi.encodePacked("Germany")),
            "This contract can only refund Tokens from Switzerland or Germany!"
            );
        require(RCTContract.ownerOf(_tokenID) == msg.sender, "You are not the owner of this token!");
        bool isRefunded = RCTContract.getNFTData(_tokenID).isRefunded;
        require(isRefunded == false, "This Token has already been refunded or is a BuyerToken!");    
        
        uint40 refundAmount;
        (uint56[] memory IDs, uint8[] memory percentages) = RCTContract.getUsedProducts(_tokenID);
        for (uint24 i = 0; i < IDs.length; i++) {
            uint40 tax = RCTContract.getNFTData(IDs[i]).total_price * 100 * OracleContract.getVATRate(RCTContract.getNFTData(IDs[i]).current_country) / 1000;
            refundAmount += tax * percentages[i] / 100;
            if (keccak256(abi.encodePacked(RCTContract.getNFTData(IDs[i]).country_of_sale)) == keccak256(abi.encodePacked("Switzerland"))) {
                refundAmount = refundAmount / OracleContract.getExchangeRate() * 1000;
            }
        }

        if (refundAmount != 0) {
            this.transferGovernment(msg.sender, refundAmount);
            RCTContract.changeRefundStatus(_tokenID);
        }
    }

    /**
     * @dev Allows users to buy VAT tokens by withdrawing from their token credit, if the token credit is 0, 
     *      the TokenCredit is deleted. The function can only be accessed, when the 'TokenCredit' is higher
     *      than the amount used as input for the function
     * @param _amount The amount of VAT tokens to buy from the TokenCredit
     */
    function BuyVATTokens(uint40 _amount) external {
        require(TokenCredit[msg.sender] >= _amount * 100, "Your balance is not sufficient!");
        this.mint(msg.sender, _amount * 100);
        TokenCredit[msg.sender] -= _amount * 100;
        if (TokenCredit[msg.sender] == 0) {
            delete TokenCredit[msg.sender];
        }
        emit TokensBought(msg.sender, _amount);
    }

    /**
     * @dev Allows users to sell VAT tokens by withdrawing from their token balance. If the token balance is equal or 
     *      higher than the amount. After successful compliance the government transfers EUR back to the companies
     *      bank account
     * @param _amount The amount of VAT tokens to sell from the balance
     */
    function SellVATTokens(uint40 _amount, string memory otherInformation) external {
        require(balanceOf(msg.sender) >= _amount * 100, "You have not enough VAT_GER Tokens!");
        _transfer(msg.sender, address(this), _amount * 100);
        emit PaymentToBeReleased(msg.sender, _amount, otherInformation);
    }

    /**
     * @dev This function allows the owner of the VATToken_DE Contract to sell VAT_CH_Tokens if received. The VAT
     *      amount is refunded in fiat money to the bank account of the seller of the VAT tokens
     * @param _amount, The amount of VAT tokens to sell
     * @param otherInformation, Other information, like e.g. the number of the bank account, etc. 
     */
    function sellVAT_CH_Tokens(uint40 _amount, string memory otherInformation) external onlyOwner{
        VATToken_CH_Contract.SellVATTokens(_amount, otherInformation);
    }
}
