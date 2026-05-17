// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract GOV is ERC20, ERC20Permit, ERC20Votes {
    uint256 public constant MAX_SUPPLY = 100_000_000e18;

    constructor()
        ERC20("GameGov", "GOV")
        ERC20Permit("GameGov")
    {
        _mint(msg.sender, MAX_SUPPLY);
    }

    function _update(address from, address to, uint256 value)
        internal override(ERC20, ERC20Votes)
    {
        super._update(from, to, value);
    }

    function nonces(address owner)
        public view override(ERC20Permit, Nonces) returns (uint256)
    {
        return super.nonces(owner);
    }
}