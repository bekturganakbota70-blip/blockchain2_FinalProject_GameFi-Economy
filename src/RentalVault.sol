// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract RentalVault is ERC4626, Ownable {
    event YieldAdded(address indexed source, uint256 amount);

    constructor(IERC20 _govToken)
        ERC4626(_govToken)
        ERC20("GameFi Vault Shares", "gfVAULT")
        Ownable(msg.sender)
    {}

    function addYield(uint256 amount) external onlyOwner {
        SafeERC20.safeTransferFrom(IERC20(asset()), msg.sender, address(this), amount);
        emit YieldAdded(msg.sender, amount);
    }
}