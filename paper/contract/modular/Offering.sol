// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Registry.sol";

abstract contract Offering is Registry {

    uint256 public offeringPrice;
    uint256 public offeringAmount;
    bool public offering;

    function startOffering(uint _price, uint _amount) public onlyOwners returns (bool) {
        offeringPrice = _price;
        offeringAmount = _amount;
        offering = true;
        return true;
    }

    function changePrice(uint _price) public onlyOwners returns (bool) {
        offeringPrice = _price;
        return true;
    }

    function changeAmount(uint _amount) public onlyOwners returns (bool) {
        offeringAmount = _amount;
        return true;
    }

    function stopOffering() public returns (bool) {
        offeringPrice = 0;
        offering = false;
        return true;
    }

    function buyTokens() public payable returns (uint) {
        require(offering, "Offering: No Tokens are being offered at the moment");
        uint256 _buyAmount = 10**decimals() * msg.value / offeringPrice;

        if (_buyAmount >= offeringAmount) {
            uint256 repayment = (msg.value - (offeringAmount * offeringPrice));
            payable(msg.sender).transfer(repayment);
            _buyAmount = offeringAmount;
            stopOffering();
        }

        _mint(msg.sender, _buyAmount);
        offeringAmount -= _buyAmount;
        return _buyAmount;
    }

    function withdraw() public onlyOwners returns (bool) {
        payable(msg.sender).transfer(address(this).balance);
        return true;
    }
}
