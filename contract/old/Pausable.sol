// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


contract Pausable {

    bool private _paused;

    event Paused(uint256 time);
    event Unpaused(uint256 time);

    constructor() {
        _paused = false;
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
        return _paused;
    }

    function pause() private virtual {
        _paused = true;
        emit Paused(block.timestamp);
    }

    function unpause() private virtual {
        _paused = false;
        emit Unpaused(block.timestamp);
    }
}