// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../src/GameItems.sol";

interface IFeed {
    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80);
}

contract ForkTest is Test {
    address constant ARB_ETH_USD = 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612;
    uint256 arbFork;

    function setUp() public {
        string memory rpc = vm.envOr("ARBITRUM_RPC", string("https://arb1.arbitrum.io/rpc"));
        arbFork = vm.createFork(rpc);
    }

    // Fork 1: Chainlink feed returns valid price
    function test_Fork_ChainlinkFeedValid() public {
        vm.selectFork(arbFork);
        (, int256 price, , uint256 updatedAt, ) = IFeed(ARB_ETH_USD).latestRoundData();
        assertGt(price, 100e8);        // > $100
        assertLt(price, 100_000e8);   // < $100,000
        assertGt(updatedAt, 0);
    }

    // Fork 2: Deploy GameItems on Arbitrum fork with real Chainlink
    function test_Fork_DeployGameItemsWithRealFeed() public {
        vm.selectFork(arbFork);
        GameItems impl = new GameItems();
        bytes memory data = abi.encodeCall(GameItems.initialize, (address(this), ARB_ETH_USD));
        GameItems items = GameItems(address(new ERC1967Proxy(address(impl), data)));
        assertTrue(items.hasRole(items.DEFAULT_ADMIN_ROLE(), address(this)));
        assertEq(items.itemPriceUsd(1), 1e8);
    }

    // Fork 3: Buy item with real ETH/USD price
    function test_Fork_BuyItemWithRealPrice() public {
        vm.selectFork(arbFork);
        GameItems impl = new GameItems();
        bytes memory data = abi.encodeCall(GameItems.initialize, (address(this), ARB_ETH_USD));
        GameItems items = GameItems(address(new ERC1967Proxy(address(impl), data)));

        (, int256 price, , , ) = IFeed(ARB_ETH_USD).latestRoundData();
        uint256 ethNeeded = (1e8 * 1e18) / uint256(price); // $1 of ETH

        address buyer = makeAddr("buyer");
        vm.deal(buyer, ethNeeded * 3);
        vm.prank(buyer);
        items.buyItem{value: ethNeeded * 2}(1, 1);
        assertEq(items.balanceOf(buyer, 1), 1);
    }
}