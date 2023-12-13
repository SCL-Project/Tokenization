// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./RCT.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/// @title VATTokenContract
/// @author Samuel Clauss & Dario Ganz
contract VATToken_CH is ERC20, ERC20Burnable, Ownable, ERC20Permit {
    address CrossBorderContract;
    ReceiptTokenContract public RCTContract;
    address private RCTAddress;

    /**
     * @dev Constructor to initialize the contract of the VATToken
     * @param initialOwner The address that will be granted the ownership of the contract.
     *        in our case the government or to be specific the tax authority
     */
    constructor(address initialOwner, address _RCTAddress)
        ERC20("VAT_CH", "VGER")
        Ownable(initialOwner)
        ERC20Permit("VATToken")
    {
        RCTContract = ReceiptTokenContract(_RCTAddress);
        RCTAddress = _RCTAddress;
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

    event PaymentToBeReleased(address company, uint256 amount);

    event TokenCreditReceived(address company, uint256 amount);

    event TokensBought(address company, uint256 amount);


    //----------------------------Mappings-------------------------------

    /**
     * @dev Mapping to store the amount of TokenCredit
     */
    mapping (address => uint256) private TokenCredit;

    //----------------------------Modifier-------------------------------

    /**
     * @dev Ensures transfers are only allowed between specific addresses and not between companies
     * @param _from The address of the sender
     * @param _to The address of the receiver
     */
    modifier transferRestriction(address _from, address _to) {
        require(_from == address(this) || _from == CrossBorderContract || _to == address(this) || _to == CrossBorderContract, "Transactions between companies are not allowed!");
        _;
    }

    /**
     * @dev Ensures only government entities can mint tokens
     */
    modifier onlyGovernment() {
        require(msg.sender == address(this) || msg.sender == CrossBorderContract || msg.sender == RCTAddress, "You are not allowed to mint VAT_CH Tokens!");
        _;
    }

    //----------------------------Functions-------------------------------

    function checkTokenCredit() public view returns(uint256) {
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
     * @dev Set or update the token credit for an address
     * @param _address The address to update
     * @param _amount The credit amount to set or add
     */
    function setTokenCredit(address _address, uint256 _amount) public onlyOwner {
        if (checkIfKeyExists(_address)) {
            TokenCredit[_address] += _amount;
        } else {
        TokenCredit[_address] = _amount;
        }
        emit TokenCreditReceived(_address, _amount);
    } 

    /**
     * @dev Mints tokens to a specified address
     * @param to The address to which the tokens are minted to
     * @param amount The amount of tokens to be minted
     */
    function mint(address to, uint256 amount) public onlyGovernment {
        _mint(to, amount);
    }

    /**
     * @dev Sets the address of the CrossBorderContract
     * @param _address The address of the CrossBorderContract
     */
    function setCBCAddress(address _address) public onlyOwner {
        CrossBorderContract = _address;
    }

    /**
     * @dev Transfers a specified amount of tokens from the contract to a specific address. 
     *      If the contract doesn't have enough tokens, the required amount gets minted.
     *      This function is restricted to the contract owner
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
    function transfer(address _to, uint256 value) public override transferRestriction(msg.sender, _to) returns(bool) {
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
    function transferFrom(address _from, address _to, uint256 value) public override transferRestriction(_from, _to) returns(bool) {
    }

    /**
     * @dev Transfers a specified amount of tokens from a given address to the contract as VAT-payment.
     *      Only callable by accounts with the role of government entities
     * @param _from The address from which the tax amount will be substracted
     * @param _amount The amount of tokens to be paid
     * @return bool Returns true if the tax payment is successful, otherwise false
     */
    function payTaxes(address _from, uint40 _amount) external onlyGovernment returns(bool) {
        if (balanceOf(_from) >= _amount) {
            _transfer(_from, address(this), _amount);
            return true;
        }
        return false;
    }

    /**
     * @dev Refunds taxes for a specific token ID by transferring the appropriate amount of VAT back to the owner of the ReceiptToken.
     *      The function calculates the refund amount based on the tax and percentages of used products associated with the token
     * @param _tokenID The ID of the token for which the tax refund is requested
     */
    function refundTaxes(uint64 _tokenID) external {
        require(
            keccak256(abi.encodePacked(RCTContract.getNFTData(_tokenID).current_country)) == keccak256(abi.encodePacked("Switzerland")),
            "This contract can only refund Tokens from Switzerland!"
            );
        require(RCTContract.ownerOf(_tokenID) == msg.sender, "You are not the owner of this token!");
        bool isRefunded = RCTContract.getNFTData(_tokenID).isRefunded;
        require(isRefunded == false, "This Token has already been refunded or is a BuyerToken!");    
        
        uint40 refundAmount;
        (uint64[] memory IDs, uint8[] memory percentages) = RCTContract.getUsedProducts(_tokenID);
        for (uint24 i = 0; i < IDs.length; i++) {
            uint40 tax = RCTContract.getNFTData(IDs[i]).VAT_amount;
            refundAmount += tax * percentages[i] / 100;
        }
        if (refundAmount != 0) {
            transferGovernment(msg.sender, refundAmount);
        }
        RCTContract.changeRefundStatus(_tokenID);
    }

    /**
     * @dev Allows users to buy VAT tokens by withdrawing from their token credit, if the token credit is 0, the TokenCredit is deleted
     * @param _amount The amount of VAT tokens to buy from the TokenCredit
     */
    function BuyVATTokens(uint40 _amount) public {
        require(TokenCredit[msg.sender] >= _amount, "Your balance is not sufficient!");
        mint(msg.sender, _amount);
        TokenCredit[msg.sender] -= _amount;
        if (TokenCredit[msg.sender] == 0) {
            delete TokenCredit[msg.sender];
        }
        emit TokensBought(msg.sender, _amount);
    }

    function SellVATTokens(uint40 _amount) public {
        require(balanceOf(msg.sender) >= _amount, "You have not enough VAT_CH Tokens!");
        _transfer(msg.sender, address(this), _amount);
        emit PaymentToBeReleased(msg.sender, _amount);
    }
}