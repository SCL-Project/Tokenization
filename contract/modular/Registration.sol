// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Shares.sol";


contract Registration is Shares {

    event Registered(address indexed account, bytes32 registrationHash);

    function registerHash(bytes32 hash) public {
        registry[msg.sender].registrationHash = hash;
        emit Registered(msg.sender, hash);
    }

    function getHash(address account) internal view returns (bytes32) {
        return registry[account].registrationHash;
    }
}