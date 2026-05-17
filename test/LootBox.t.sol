// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../src/LootBox.sol";
import "../src/GameItems.sol";
import "../src/mocks/MockVRFCoordinator.sol";
import "../src/mocks/MockPriceFeed.sol";

contract LootBoxTest is Test {
    LootBox   lootBox;
    GameItems items;
    MockVRFCoordinator vrf;
    address alice = makeAddr("alice");

    function setUp() public {
        MockPriceFeed feed = new MockPriceFeed(2000e8);
        GameItems impl = new GameItems();
        bytes memory data = abi.encodeCall(GameItems.initialize, (address(this), address(feed)));
        items = GameItems(address(new ERC1967Proxy(address(impl), data)));
        vrf     = new MockVRFCoordinator();
        lootBox = new LootBox(address(vrf), address(items), bytes32(0), 1);
        items.grantRole(items.MINTER_ROLE(), address(lootBox));
    }

    function test_OpenBox_BurnsGold() public {
        items.mint(alice, 1, 10);
        vm.prank(alice); lootBox.openBox();
        assertEq(items.balanceOf(alice, 1), 5); // 5 burned
    }

    function test_FulfillRandomWords_Potion() public {
        items.mint(alice, 1, 10);
        vm.prank(alice); uint256 id = lootBox.openBox();
        uint256[] memory w = new uint256[](1); w[0] = 0; // roll 0 → potion
        vrf.fulfillRandomWords(address(lootBox), id, w);
        assertEq(items.balanceOf(alice, 3), 3);
    }

    function test_FulfillRandomWords_Sword() public {
        items.mint(alice, 1, 10);
        vm.prank(alice); uint256 id = lootBox.openBox();
        uint256[] memory w = new uint256[](1); w[0] = 60; // roll 60 → sword
        vrf.fulfillRandomWords(address(lootBox), id, w);
        assertEq(items.balanceOf(alice, 2), 1);
    }

    function test_FulfillRandomWords_GoldJackpot() public {
        items.mint(alice, 1, 10);
        vm.prank(alice); uint256 id = lootBox.openBox();
        uint256[] memory w = new uint256[](1); w[0] = 90; // roll 90 → jackpot
        vrf.fulfillRandomWords(address(lootBox), id, w);
        assertEq(items.balanceOf(alice, 1), 25); // 5 left + 20 jackpot
    }

    function test_RevertOpenBox_NotEnoughGold() public {
        items.mint(alice, 1, 3);
        vm.prank(alice); vm.expectRevert();
        lootBox.openBox();
    }

    function test_RevertFulfill_OnlyCoordinator() public {
        uint256[] memory w = new uint256[](1);
        vm.expectRevert("Only VRF coordinator");
        lootBox.rawFulfillRandomWords(1, w);
    }

    function test_SetKeyHash() public {
        lootBox.setKeyHash(bytes32(uint256(42)));
        assertEq(lootBox.keyHash(), bytes32(uint256(42)));
    }

    function test_SetSubId() public {
        lootBox.setSubId(99);
        assertEq(lootBox.subscriptionId(), 99);
    }
}