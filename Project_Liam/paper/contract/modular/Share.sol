// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Recovery.sol";
import "./Dividends.sol";
import "./Offering.sol";
import "./Announcement.sol";

contract Share is Recovery, Offering, Dividends, Announcement {

    constructor() ERC20("Smart Contracts Lab Token", "SCLZ", 18) {
        addOwner(0x5a88f1E531916b681b399C33F519b7E2E54b5213); // Liam
        addOwner(0x3082f89471245a689bdd60EC82e6c12da97531d7); // Roman
        addOwner(0xb3A5E267F04acF7804E22A8600081f8B854e7847); // Laura
        addOwner(0xF85F88412589949dBfD6a70c76417AdBcf358249); // Patricia
        mint(msg.sender, 10000 * 1e18);
    }

    function _update(address from, address to, uint256 amount) internal override(Registry, Dividends) {
        super._update(from, to, amount);
    }
}
