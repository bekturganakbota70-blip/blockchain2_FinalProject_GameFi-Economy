// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../src/GameItems.sol";
import "../src/mocks/MockPriceFeed.sol";

contract GameItemsTest is Test {
    GameItems   items;
    MockPriceFeed feed;
    address alice = makeAddr("alice");

    uint256 constant ETH_PRICE = 2000e8;
    uint256 constant GOLD = 1; uint256 constant SWORD = 2; uint256 constant POTION = 3;

    function setUp() public {
        feed = new MockPriceFeed(int256(ETH_PRICE));
        GameItems impl = new GameItems();
        bytes memory data = abi.encodeCall(GameItems.initialize, (address(this), address(feed)));
        items = GameItems(address(new ERC1967Proxy(address(impl), data)));
    }

    function test_Initialize_AdminRole() public view {
        assertTrue(items.hasRole(items.DEFAULT_ADMIN_ROLE(), address(this)));
    }
    function test_Initialize_MinterRole() public view {
        assertTrue(items.hasRole(items.MINTER_ROLE(), address(this)));
    }
    function test_Initialize_Prices() public view {
        assertEq(items.itemPriceUsd(GOLD), 1e8);
        assertEq(items.itemPriceUsd(SWORD), 5e8);
    }
    function test_Initialize_CraftCosts() public view {
        assertEq(items.craftCostGold(SWORD), 10);
        assertEq(items.craftCostGold(POTION), 5);
    }

    function test_Mint() public {
        items.mint(alice, GOLD, 100);
        assertEq(items.balanceOf(alice, GOLD), 100);
    }
    function test_RevertMint_NotMinter() public {
        vm.prank(alice); vm.expectRevert();
        items.mint(alice, GOLD, 100);
    }

    function test_Burn() public {
        items.mint(alice, GOLD, 100);
        items.burn(alice, GOLD, 40);
        assertEq(items.balanceOf(alice, GOLD), 60);
    }
    function test_RevertBurn_NotMinter() public {
        items.mint(alice, GOLD, 100);
        vm.prank(alice); vm.expectRevert();
        items.burn(alice, GOLD, 100);
    }

    function test_BuyItem() public {
        uint256 ethNeeded = (5e8 * 1e18) / ETH_PRICE;
        vm.deal(alice, ethNeeded * 2);
        vm.prank(alice);
        items.buyItem{value: ethNeeded}(SWORD, 1);
        assertEq(items.balanceOf(alice, SWORD), 1);
    }
    function test_RevertBuyItem_InsufficientETH() public {
        vm.deal(alice, 0.001 ether);
        vm.prank(alice); vm.expectRevert("Insufficient ETH");
        items.buyItem{value: 0.001 ether}(SWORD, 1);
    }
    function test_RevertBuyItem_StalePrice() public {
        vm.warp(block.timestamp + 2 hours);
        vm.deal(alice, 1 ether);
        vm.prank(alice); vm.expectRevert("Stale price");
        items.buyItem{value: 1 ether}(SWORD, 1);
    }

    function test_Craft_Sword() public {
        items.mint(alice, GOLD, 50);
        vm.prank(alice); items.craft(SWORD, 3);
        assertEq(items.balanceOf(alice, SWORD), 3);
        assertEq(items.balanceOf(alice, GOLD), 20);
    }
    function test_RevertCraft_NotEnoughGold() public {
        items.mint(alice, GOLD, 5);
        vm.prank(alice); vm.expectRevert();
        items.craft(SWORD, 1);
    }

    function test_SetCraftCost() public {
        items.setCraftCost(SWORD, 20);
        assertEq(items.craftCostGold(SWORD), 20);
    }

    // Fuzz
    function testFuzz_Mint(uint256 amount) public {
        amount = bound(amount, 1, 1_000_000);
        items.mint(alice, GOLD, amount);
        assertEq(items.balanceOf(alice, GOLD), amount);
    }
    function testFuzz_Craft(uint8 n) public {
        uint256 amt = bound(uint256(n), 1, 10);
        items.mint(alice, GOLD, amt * 10);
        vm.prank(alice); items.craft(SWORD, amt);
        assertEq(items.balanceOf(alice, SWORD), amt);
    }
}