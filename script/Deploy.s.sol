// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/governance/TimelockController.sol";
import "../src/GOV.sol";
import "../src/GameItems.sol";
import "../src/ItemFactory.sol";
import "../src/GameAMM.sol";
import "../src/RentalVault.sol";
import "../src/LootBox.sol";
import "../src/GameGovernor.sol";

contract Deploy is Script {
    address constant CHAINLINK_ETH_USD = 0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165;
    address constant VRF_COORDINATOR   = 0x50d47e4142598E3411aA864e08a44284e471AC6f;
    bytes32 constant VRF_KEYHASH       = 0x027f94ff1465b3525f9fc03e9ff7d6d2c0953482246dd6ae0b9f7d7b00000000;
    uint64  constant VRF_SUBSCRIPTION  = 1;

    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address deployer    = vm.addr(deployerKey);
        vm.startBroadcast(deployerKey);

        GOV gov = new GOV();
        console.log("GOV:", address(gov));

        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](1);
        executors[0] = address(0);
        TimelockController timelock = new TimelockController(2 days, proposers, executors, deployer);
        console.log("Timelock:", address(timelock));

        GameItems implementation = new GameItems();
        ItemFactory factory = new ItemFactory(address(implementation));
        address itemsProxy = factory.deploy(deployer, CHAINLINK_ETH_USD);
        GameItems items = GameItems(itemsProxy);
        console.log("GameItems:", itemsProxy);

        GameAMM amm = new GameAMM(address(gov), itemsProxy);
        console.log("GameAMM:", address(amm));

        RentalVault vault = new RentalVault(IERC20(address(gov)));
        console.log("RentalVault:", address(vault));

        LootBox lootBox = new LootBox(VRF_COORDINATOR, itemsProxy, VRF_KEYHASH, VRF_SUBSCRIPTION);
        items.grantRole(keccak256("MINTER_ROLE"), address(lootBox));
        console.log("LootBox:", address(lootBox));

        GameGovernor governor = new GameGovernor(gov, timelock);
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.CANCELLER_ROLE(), address(governor));
        timelock.renounceRole(timelock.DEFAULT_ADMIN_ROLE(), deployer);
        console.log("Governor:", address(governor));

        vm.stopBroadcast();
        console.log("Chain ID:", block.chainid);
    }
}
