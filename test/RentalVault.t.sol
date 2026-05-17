// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/RentalVault.sol";
import "../src/GOV.sol";

contract RentalVaultTest is Test {
    RentalVault vault;
    GOV gov;
    address alice = makeAddr("alice");
    address bob   = makeAddr("bob");

    function setUp() public {
        gov   = new GOV();
        vault = new RentalVault(IERC20(address(gov)));
        gov.transfer(alice, 10_000e18);
        gov.transfer(bob,   10_000e18);
    }

    function test_VaultName()   public view { assertEq(vault.name(),   "GameFi Vault Shares"); }
    function test_VaultSymbol() public view { assertEq(vault.symbol(), "gfVAULT"); }
    function test_Asset()       public view { assertEq(vault.asset(),  address(gov)); }

    function test_Deposit() public {
        vm.startPrank(alice);
        gov.approve(address(vault), 1_000e18);
        uint256 shares = vault.deposit(1_000e18, alice);
        vm.stopPrank();
        assertGt(shares, 0);
        assertEq(vault.totalAssets(), 1_000e18);
    }

    function test_Redeem() public {
        uint256 shares = _deposit(alice, 1_000e18);
        vm.startPrank(alice);
        uint256 assets = vault.redeem(shares, alice, alice);
        vm.stopPrank();
        assertApproxEqAbs(assets, 1_000e18, 1);
    }

    function test_AddYield_IncreasesShareValue() public {
        uint256 shares = _deposit(alice, 1_000e18);
        gov.approve(address(vault), 500e18);
        vault.addYield(500e18);
        assertGt(vault.previewRedeem(shares), 1_000e18);
    }

    function test_RevertAddYield_NotOwner() public {
        vm.prank(alice); vm.expectRevert();
        vault.addYield(100e18);
    }

    function test_TwoDepositors_ShareYield() public {
        _deposit(alice, 1_000e18);
        _deposit(bob,   1_000e18);
        gov.approve(address(vault), 200e18);
        vault.addYield(200e18);
        assertApproxEqAbs(vault.previewRedeem(vault.balanceOf(alice)), 1_100e18, 1e15);
        assertApproxEqAbs(vault.previewRedeem(vault.balanceOf(bob)),   1_100e18, 1e15);
    }

    // Fuzz
    function testFuzz_Deposit(uint256 amount) public {
        amount = bound(amount, 1e15, 10_000e18);
        gov.transfer(alice, amount);
        vm.startPrank(alice);
        gov.approve(address(vault), amount);
        vault.deposit(amount, alice);
        vm.stopPrank();
        assertEq(vault.totalAssets(), amount);
    }

    function testFuzz_DepositAndRedeem(uint256 amount) public {
        amount = bound(amount, 1e15, 10_000e18);
        gov.transfer(alice, amount);
        uint256 shares = _depositAmount(alice, amount);
        vm.startPrank(alice);
        uint256 assets = vault.redeem(shares, alice, alice);
        vm.stopPrank();
        assertApproxEqAbs(assets, amount, 1);
    }

    function testFuzz_YieldDistribution(uint256 yield) public {
        _deposit(alice, 1_000e18);
        yield = bound(yield, 1e15, 5_000e18);
        gov.approve(address(vault), yield);
        vault.addYield(yield);
        assertEq(vault.totalAssets(), 1_000e18 + yield);
    }

    function _deposit(address user, uint256 amount) internal returns (uint256) {
        vm.startPrank(user);
        gov.approve(address(vault), amount);
        uint256 s = vault.deposit(amount, user);
        vm.stopPrank();
        return s;
    }
    function _depositAmount(address user, uint256 amount) internal returns (uint256) {
        return _deposit(user, amount);
    }
}