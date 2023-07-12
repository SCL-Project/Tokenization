// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./ERC20.sol";

abstract contract Registry is ERC20 {

    struct InvestorData {
        uint256 shareBalance;
        uint256 fractionalPartOfTokenBalance;
        bytes32 registrationHash;
        bool recoverable;
        uint timeOfFirstUse;
    }

    mapping(address => InvestorData) public registry;
        uint256 private fractionedShares;
    uint256 private ONE_TOKEN;

    constructor() {
        ONE_TOKEN = 10 ** decimals();
    }

    function shareBalanceOf(address account) public view returns (uint256) {
        return registry[account].shareBalance;
    }

    function fractionalPartOfTokenBalanceOf(address account) public view returns (uint256) {
        return registry[account].fractionalPartOfTokenBalance;
    }

    function totalFractionedSupply() public view returns (uint256) {
        return fractionedShares;
    }

    function totalFullSupply() public view returns (uint256) {
        return totalSupply() - fractionedShares;
    }

    function calculateShares(address account) internal {
        uint256 tokens = balanceOf(account);
        uint256 shares = tokens / ONE_TOKEN;
        uint256 fractions = tokens % ONE_TOKEN;

        registry[account].shareBalance = shares;
        registry[account].fractionalPartOfTokenBalance = fractions;
    }

    function _update(address from, address to, uint256 amount) internal virtual override {
        super._update(from, to, amount);

        uint256 fractionsFromBefore = registry[from].fractionalPartOfTokenBalance;
        uint256 fractionsToBefore = registry[to].fractionalPartOfTokenBalance;
        
        if (from != address(0)) {
            calculateShares(from);
            if (registry[from].timeOfFirstUse == 0) {
                registry[from].timeOfFirstUse = block.timestamp;
            }
        }

        if (to != address(0)) {
            calculateShares(to);
            if (registry[to].timeOfFirstUse == 0) {
                registry[to].timeOfFirstUse = block.timestamp;
            }
        }

        uint256 fractionsFromAfter = registry[from].fractionalPartOfTokenBalance;
        uint256 fractionsToAfter = registry[to].fractionalPartOfTokenBalance;

        fractionedShares += (fractionsFromAfter - fractionsFromBefore) + (fractionsToAfter - fractionsToBefore);
    }
}
