// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/GOV.sol";

contract GOVTest is Test {
    GOV gov;
    address alice = makeAddr("alice");
    address bob   = makeAddr("bob");

    function setUp() public { gov = new GOV(); }

    function test_Name()     public view { assertEq(gov.name(),   "GameGov"); }
    function test_Symbol()   public view { assertEq(gov.symbol(), "GOV"); }
    function test_Decimals() public view { assertEq(gov.decimals(), 18); }

    function test_TotalSupply() public view {
        assertEq(gov.totalSupply(), 100_000_000e18);
    }

    function test_InitialBalance() public view {
        assertEq(gov.balanceOf(address(this)), 100_000_000e18);
    }

    function test_Transfer() public {
        gov.transfer(alice, 1_000e18);
        assertEq(gov.balanceOf(alice), 1_000e18);
    }

    function test_RevertTransfer_InsufficientBalance() public {
        vm.prank(alice);
        vm.expectRevert();
        gov.transfer(bob, 1e18);
    }

    function test_Approve() public {
        gov.approve(alice, 500e18);
        assertEq(gov.allowance(address(this), alice), 500e18);
    }

    function test_TransferFrom() public {
        gov.transfer(alice, 1_000e18);
        vm.prank(alice); gov.approve(bob, 500e18);
        vm.prank(bob);   gov.transferFrom(alice, bob, 500e18);
        assertEq(gov.balanceOf(bob), 500e18);
    }

    function test_SelfDelegate() public {
        gov.delegate(address(this));
        assertEq(gov.getVotes(address(this)), 100_000_000e18);
    }

    function test_DelegateToOther() public {
        gov.transfer(alice, 1_000e18);
        vm.prank(alice); gov.delegate(bob);
        assertEq(gov.getVotes(bob), 1_000e18);
    }

    function test_VotingPower_ZeroBeforeDelegate() public {
        gov.transfer(alice, 1_000e18);
        assertEq(gov.getVotes(alice), 0);
    }

    function test_NoncesStartAtZero() public view {
        assertEq(gov.nonces(alice), 0);
    }

    // Fuzz
    function testFuzz_Transfer(uint256 amount) public {
        amount = bound(amount, 0, 100_000_000e18);
        gov.transfer(alice, amount);
        assertEq(gov.balanceOf(alice), amount);
    }

    function testFuzz_DelegateVotingPower(uint256 amount) public {
        amount = bound(amount, 1, 100_000_000e18);
        gov.transfer(alice, amount);
        vm.prank(alice); gov.delegate(alice);
        assertEq(gov.getVotes(alice), amount);
    }
}