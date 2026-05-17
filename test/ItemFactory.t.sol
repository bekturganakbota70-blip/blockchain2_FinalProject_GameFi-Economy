// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/ItemFactory.sol";
import "../src/GameItems.sol";
import "../src/mocks/MockPriceFeed.sol";

contract ItemFactoryTest is Test {
    ItemFactory   factory;
    GameItems     impl;
    MockPriceFeed feed;
    address alice = makeAddr("alice");

    function setUp() public {
        feed    = new MockPriceFeed(2000e8);
        impl    = new GameItems();
        factory = new ItemFactory(address(impl));
    }

    function test_Implementation() public view {
        assertEq(factory.implementation(), address(impl));
    }

    function test_Deploy_CREATE() public {
        address proxy = factory.deploy(address(this), address(feed));
        assertFalse(proxy == address(0));
        assertEq(factory.collectionsCount(), 1);
    }

    function test_Deploy_InitializesCorrectly() public {
        address proxy = factory.deploy(address(this), address(feed));
        assertTrue(GameItems(proxy).hasRole(GameItems(proxy).DEFAULT_ADMIN_ROLE(), address(this)));
    }

    function test_Deploy2_CREATE2() public {
        address proxy = factory.deploy2(address(this), address(feed), keccak256("salt1"));
        assertFalse(proxy == address(0));
    }

    function test_PredictAddress_MatchesActual() public {
        bytes32 salt  = keccak256("predict");
        address pred  = factory.predictAddress(address(this), address(feed), salt);
        address actual = factory.deploy2(address(this), address(feed), salt);
        assertEq(pred, actual);
    }

    function test_IsRegistered_Yul() public {
        address proxy = factory.deploy(address(this), address(feed));
        assertTrue(factory.isRegistered(proxy));
        assertFalse(factory.isRegistered(alice));
    }

    function test_IsRegistered_YulMatchesSolidity() public {
        address p = factory.deploy(address(this), address(feed));
        assertEq(factory.isRegistered(p), factory.isRegisteredSolidity(p));
        assertEq(factory.isRegistered(alice), factory.isRegisteredSolidity(alice));
    }

    function test_DifferentSalts_DifferentAddresses() public {
        address p1 = factory.deploy2(address(this), address(feed), bytes32(uint256(1)));
        address p2 = factory.deploy2(address(this), address(feed), bytes32(uint256(2)));
        assertFalse(p1 == p2);
    }
}