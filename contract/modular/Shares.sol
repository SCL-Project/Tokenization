// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./ERC20.sol";

contract Shares is ERC20 {

    struct InvestorData {
        uint256 shareBalance;
        uint256 fractionalPartOfTokenBalance;
        bytes32 registrationHash;
        bool recoverable;
    }

    mapping(address => InvestorData) public registry;
    uint256 private ONE_TOKEN;
    address private registrar;

    constructor() ERC20("Smart Contract Lab Token", "SCL", 18) {
        ONE_TOKEN = 10 ** decimals();
        registrar = msg.sender;
        mint(msg.sender, 100000 * ONE_TOKEN);
        mint(0x5a88f1E531916b681b399C33F519b7E2E54b5213, 100000 * ONE_TOKEN);
    }

    function shareBalanceOf(address account) public view virtual returns (uint256) {
        return registry[account].shareBalance;
    }

    function fractionalPartOfTokenBalanceOf(address account) public view virtual returns (uint256) {
        return registry[account].fractionalPartOfTokenBalance;
    }

    function calculateShares(address account) internal virtual {
        uint256 tokens = balanceOf(account);
        uint256 shares = tokens / ONE_TOKEN;
        uint256 fractions = tokens % ONE_TOKEN;

        registry[account].shareBalance = shares;
        registry[account].fractionalPartOfTokenBalance = fractions;
    }

    function _update(address from, address to, uint256 amount) internal virtual override {
        super._update(from, to, amount);

        uint256 fractions = amount % ONE_TOKEN;
        uint256 fractionsFrom = registry[from].fractionalPartOfTokenBalance;
        uint256 fractionsTo = 1 - registry[to].fractionalPartOfTokenBalance;

        if (fractions > fractionsFrom) {
            registry[registrar].shareBalance += 1;
        }

        if (fractions > fractionsTo) {
            registry[registrar].shareBalance -= 1;
        }

        if (from != address(0)) {
            calculateShares(from);
        }

        if (to != address(0)) {
            calculateShares(to);
        }
    }     
}