// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


contract Ownable {

    mapping(address => bool) private owners;

    modifier onlyOwner {
        require(owners[msg.sender]);
        _;
    }

    constructor() {
        owners[msg.sender] = true;
        owners[0x5a88f1E531916b681b399C33F519b7E2E54b5213] = true; // Liam
        owners[0x3082f89471245a689bdd60EC82e6c12da97531d7] = true; // Roman
        owners[0xb3A5E267F04acF7804E22A8600081f8B854e7847] = true; // Laura
        owners[0xF85F88412589949dBfD6a70c76417AdBcf358249] = true; // Patricia
    }

    function addOwner(address _newOwner) public onlyOwners returns (bool) {
        owners[_newOwner] = true; return true;
    }

    function removeOwner(address _oldOwner) public onlyOwners returns (bool) {
        owners[_oldOwner] = false; return true;
    }
}
