// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


contract Ownable {

    mapping(address => bool) private ownersMap;
    address[] private ownersList;

    modifier onlyOwners {
        require(ownersMap[msg.sender], "Ownable: You are not an owner");
        _;
    }

    constructor() {
        ownersMap[msg.sender] = true;
        ownersList.push(msg.sender);
    }

    function addOwner(address _newOwner) public onlyOwners returns (bool) {
        ownersMap[_newOwner] = true;
        ownersList.push(_newOwner);
        return true;
    }

    function removeOwner(address _oldOwner) public onlyOwners returns (bool) {
        ownersMap[_oldOwner] = false;
        for (uint i = 0; i < ownersList.length; i++) {
            if (ownersList[i] == _oldOwner) {
                ownersList[i] = ownersList[ownersList.length - 1];
                ownersList.pop();
                break;
            }
        }
        return true;
    }

    function owners() public view returns (address[] memory) {
        return ownersList;
    }
}
