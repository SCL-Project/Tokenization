// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Registration.sol";


abstract contract Recovery is Registration {

    uint256 public recoveryPrice;
    event AskedForRecovery(address indexed account);
    event Recovered(address indexed account);


    constructor() {
        recoveryPrice = 1e18; // default: recovery costs 1 Ether/Matic
    }

    function askForRecovery(address account) public payable {
        require(msg.value >= recoveryPrice, "Not enough ether sent."); // investor should be charged in case of recovery
        require(registry[account].registrationHash != 0, "Account must be registered.");
        registry[account].recoverable = true;
        emit AskedForRecovery(account);
    }

    function setRecoveryPrice(uint256 price) public onlyOwners {
        recoveryPrice = price;
    }

    function recover(address oldAddress, address newAddress) public onlyOwners whenNotPaused {
        require(oldAddress != newAddress, "Old address cannot be the same as new address.");
        require(balanceOf(newAddress) == 0, "New address must not be in use.");
        require(registry[oldAddress].recoverable, "Old address not marked for recovery. Please ask for recovery first.");

        registry[newAddress] = registry[oldAddress];
        delete registry[oldAddress];
        emit Recovered(oldAddress);
    }
}
