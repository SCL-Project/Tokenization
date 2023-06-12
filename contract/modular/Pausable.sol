// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


contract Pausable {

    bool private paused;

    event Paused(uint256 time);
    event Unpaused(uint256 time);

    constructor() {
        paused = false;
    }

    modifier whenNotPaused() {
        require(paused == false, "Pausable: Contract is not paused");
        _;
    }

    modifier whenPaused() {
        require(paused == true, "Pausable: Contract is paused");
        _;
    }

    function isPaused() public view returns (bool) {
        return paused;
    }

    function pause() public virtual {
        paused = true;
        emit Paused(block.timestamp);
    }

    function unpause() public virtual {
        paused = false;
        emit Unpaused(block.timestamp);
    }
}
