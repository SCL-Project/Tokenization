// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SCL_Equity_Token is ERC20, ERC20Burnable, Pausable, Ownable {

    string private tokenName = "Smart Contract Lab Token";
    string private tokenSymbol = "SCLZ";
    uint8 private _decimals = 18;
    uint public offeringPrice = 0;
    uint public offeringAmount = 0;
    bool public offering = false;
    address[] private investorsList;
    mapping(string => address) private identification;
    mapping(address => string) private reverseIdentification;
    mapping(string => bool) private availableCodes;
    mapping(address => address) private recoveryAddresses;
    mapping(address => string) private declaredLost;
    mapping(address => bool) private owners;
    event _Announcement(uint date, string announcement);
    event RecoveryAddressSet(address _address, address _recoveryAddress);
    event AddressDeclaredLost(string _identifier, address _lostAddress);
    event InvestorRegistered(string _identifier, address _address);
    modifier onlyRegistered {require(bytes(reverseIdentification[msg.sender]).length != 0); _;}
    modifier whenOffering {require(offering); _;}
    modifier onlyOwners {require(owners[msg.sender]); _;}

    constructor() ERC20(tokenName, tokenSymbol) {
        owners[msg.sender] = true;
        owners[0x5a88f1E531916b681b399C33F519b7E2E54b5213] = true; // Liam
        owners[0x3082f89471245a689bdd60EC82e6c12da97531d7] = true; // Roman
        owners[0xb3A5E267F04acF7804E22A8600081f8B854e7847] = true; // Laura
        owners[0xF85F88412589949dBfD6a70c76417AdBcf358249] = true; // Patricia
    }

    function addOwner(address _newOwner) public onlyOwners returns (bool) {
        owners[_newOwner] = true; return true;}

    function removeOwner(address _oldOwner) public onlyOwners returns (bool) {
        owners[_oldOwner] = false; return true;}

    function pause() public onlyOwners {_pause();}

    function unpause() public onlyOwners {_unpause();}

    function approveCode(string memory _code) public onlyOwners returns (bool) {
        availableCodes[_code] = true;
        return true;}

    function registerInvestor(string memory _code) public returns(bool) {
        require(availableCodes[_code] == true, "This code is not available.");
        identification[_code] = msg.sender; reverseIdentification[msg.sender] = _code;
        availableCodes[_code] = false;
        emit InvestorRegistered(_code, msg.sender);
        return true;}

    function lookUpIdentifier(string memory _identifier) public onlyOwners view returns (address) {
        require(identification[_identifier] != address(0), "This code is not assigned.");
        return identification[_identifier];}

    function lookUpWallet(address _address) public onlyOwners view returns (string memory) {
        require(bytes(reverseIdentification[_address]).length != 0, "This wallet is not registered.");
        return reverseIdentification[_address];}

    function startOffering(uint _price, uint _amount) public onlyOwners returns (bool) {
        offeringPrice = _price; offering = true; offeringAmount = _amount * 10 ** _decimals;
        return true;}

    function changePrice(uint _price) public onlyOwners returns (bool) {
        offeringPrice = _price; return true;}

    function changeAmount(uint _amount) public onlyOwners returns (bool) {
        offeringAmount = _amount * 10 ** _decimals; return true;}

    function stopOffering() public onlyOwners returns (bool) {
        offeringPrice = 0; offering = false; return true;}

    function buyTokens() public payable whenOffering returns (uint) {
        uint _buyAmount = msg.value * 10 ** 18 / offeringPrice;
        if (_buyAmount > offeringAmount) {
            uint repayment = (msg.value - (offeringAmount * offeringPrice));
            payable(msg.sender).transfer(repayment);
            _buyAmount = offeringAmount;
            stopOffering();}
        _mint(msg.sender, _buyAmount);
        offeringAmount -= _buyAmount;
        return _buyAmount;}

    function withdraw() public onlyOwners returns (bool) {
        payable(msg.sender).transfer(address(this).balance);
        return true;}

    function payDividends() public payable onlyOwners returns (bool) { // we need to check divisibility
        uint _amountPerToken = msg.value * 10 ** 18 / totalSupply();
        for (uint i = 0; i < investorsList.length; i++) {
            uint _dividend = balanceOf(investorsList[i]) * _amountPerToken / 10 ** 18;
            payable(investorsList[i]).transfer(_dividend);}
        return true;}

    function mint(address to, uint256 amount) public onlyOwners {_mint(to, amount * 10 ** 18);}

    function burn(uint256 amount) public onlyOwners override {super.burn(amount);}

    function burnFrom(address, uint256) public view override onlyOwner {
        revert("The burnFrom-function has been disabled.");}

    function renounceOwnership() public view override onlyOwners {
        revert("The renounceOwnership-function has been disabled");}

    function decimals() public view override returns (uint8) {return _decimals;}

    function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal whenNotPaused override {
        super._beforeTokenTransfer(_from, _to, _amount);}

    function announcement(string memory _announcement) public onlyOwners returns(bool) {
        emit _Announcement(block.timestamp, _announcement); return true;}

    function setRecoveryAddress(address _recoveryAddress) external {
        recoveryAddresses[msg.sender] = _recoveryAddress;
        approve(_recoveryAddress, totalSupply()); //weird formulation
        emit RecoveryAddressSet(msg.sender, _recoveryAddress);}

    function declareLost(address _lostAddress) public returns (bool) {
        require(msg.sender == recoveryAddresses[_lostAddress], "To call this function, you first must have set up a recovery address. Make sure your are calling the function from the recovery address you set up.");
        uint256 _amount = balanceOf(_lostAddress);
        transferFrom(_lostAddress, msg.sender, _amount);
        emit AddressDeclaredLost(reverseIdentification[_lostAddress], _lostAddress);
        emit InvestorRegistered(reverseIdentification[_lostAddress], msg.sender);
        declaredLost[_lostAddress] = lookUpWallet(_lostAddress);
        reverseIdentification[msg.sender] = reverseIdentification[_lostAddress];
        reverseIdentification[_lostAddress] = "";
        identification[reverseIdentification[_lostAddress]] = msg.sender;
        return true;}
}
