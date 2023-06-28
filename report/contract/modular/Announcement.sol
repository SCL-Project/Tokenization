// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Registry.sol";

abstract contract Announcement is Registry {

    event _Announcement(uint date, string announcement);

    function announcement(string memory _announcement) public onlyOwners returns(bool) {
        emit _Announcement(block.timestamp, _announcement);
        return true;
        }
}
