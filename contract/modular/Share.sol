// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Recovery.sol";
import "./Dividends.sol";
import "./Offering.sol";

contract Share is Recovery, Offering, Dividends {

    constructor() ERC20("Smart Contracts Lab Token", "SCLZ", 18) {}

    function _update(address from, address to, uint256 amount) internal override(Registry, Dividends) {
        super._update(from, to, amount);
    }
}
