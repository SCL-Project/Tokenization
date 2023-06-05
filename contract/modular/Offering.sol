// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Dividends.sol";

contract Offering is Dividends {

    uint256 public offeringPrice;
    uint256 public offeringAmount;
    bool public offering;

    modifier whenOffering {
        require(offering, "Offering: No Tokens are being offered at the moment");
        _;
    }

    function startOffering(uint _price, uint _amount) public onlyOwners returns (bool) {
        offeringPrice = _price;
        offering = true;
        offeringAmount = _amount;
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

    function stopOffering() public onlyOwners returns (bool) {
        offeringPrice = 0; offering = false;
        return true;
    }

    function buyTokens() public payable whenOffering returns (uint256) {
        uint256 _buyAmount = msg.value / offeringPrice;

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