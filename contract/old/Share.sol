// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Contract_Christian.sol";

contract Share is ERC20 {

    uint public offeringPrice = 0;
    uint public offeringAmount = 0;
    bool public offering = false;
    address[] private investorsList;
    modifier whenOffering {require(offering); _;}

    constructor() {}

    function startOffering(uint _price, uint _amount) public onlyOwners returns (bool) {
        offeringPrice = _price;
        offering = true;
        offeringAmount = _amount * 10 ** _decimals;
        return true;
    }

    function changePrice(uint _price) public onlyOwners returns (bool) {
        offeringPrice = _price;
        return true;
    }

    function changeAmount(uint _amount) public onlyOwners returns (bool) {
        offeringAmount = _amount * 10 ** _decimals;
        return true;
    }

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

    function payDividends() public payable onlyOwners returns (bool) { // pushes dividends to investors
        uint _amountPerToken = msg.value * 10 ** 18 / totalSupply();
        for (uint i = 0; i < investorsList.length; i++) {
            uint _dividend = shareBalanceOf(investorsList[i]) * _amountPerToken / 10 ** 18;
            payable(investorsList[i]).transfer(_dividend);}
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        super._transfer(sender, recipient, amount);
        if (registry[sender].tokenBalance == 0) {
            for (uint i = 0; i < investorsList.length; i++) {
                if (investorsList[i] == sender) {
                    investorsList[i] = investorsList[investorsList.length - 1];
                    investorsList.pop();
                    break;
                }
            }
        }
        if (registry[recipient].tokenBalance >= 0) {
            investorsList.push(recipient);
        }
    }


    function _mint(address account, uint256 amount) internal override {
        super._mint(account, amount);
        if (registry[account].tokenBalance >= 0) {
            investorsList.push(account);
        }
    }
    function _burn(address account, uint256 amount) internal override {
        super._burn(account, amount);
        if (registry[account].tokenBalance == 0) {
            for (uint i = 0; i < investorsList.length; i++) {
                if (investorsList[i] == account) {
                    investorsList[i] = investorsList[investorsList.length - 1];
                    investorsList.pop();
                    break;
                }
            }
        }
    }
}