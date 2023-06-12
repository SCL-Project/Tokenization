// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Offering.sol";
import "./Registration.sol";

abstract contract Dividends is Registration {

    address[] private investorsList;
    mapping(address => bool) private eligibleInvestors;

    function payDividends() public payable onlyOwners returns (bool) {
        uint256 _amountPerToken = msg.value / totalSupply();
        for (uint32 i = 0; i < investorsList.length; i++) {
            if (registry[investorsList[i]].registrationHash != 0) {
                uint256 _dividend = shareBalanceOf(investorsList[i]) * _amountPerToken;
                payable(investorsList[i]).transfer(_dividend);
            }
        }
        return true;
    }

    function _update(address from, address to, uint256 amount) internal virtual override {
        super._update(from, to, amount);

        if (shareBalanceOf(from) > 0 && !eligibleInvestors[from] && registry[from].registrationHash != 0) {
            eligibleInvestors[from] = true;
            investorsList.push(from);
        }

        if (shareBalanceOf(to) > 0 && !eligibleInvestors[to] && registry[to].registrationHash != 0) {
            eligibleInvestors[to] = true;
            investorsList.push(to);
        }
    }
}
