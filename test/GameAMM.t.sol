// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../src/GameAMM.sol";
import "../src/GOV.sol";

contract MockToken is ERC20 {
    constructor() ERC20("Mock","MCK") { _mint(msg.sender, 10_000_000e18); }
}

contract GameAMMTest is Test {
    GameAMM   amm;
    GOV       tokenA;
    MockToken tokenB;
    address alice = makeAddr("alice");
    address bob   = makeAddr("bob");

    function setUp() public {
        tokenA = new GOV();
        tokenB = new MockToken();
        amm    = new GameAMM(address(tokenA), address(tokenB));
        tokenA.transfer(alice, 200_000e18);
        tokenB.transfer(alice, 200_000e18);
        tokenA.transfer(bob, 10_000e18);
    }

    function test_AddLiquidity_Initial() public {
        uint256 lp = _addLiquidity(alice, 10_000e18, 10_000e18);
        assertGt(lp, 0);
        assertEq(amm.reserve0(), 10_000e18);
        assertEq(amm.reserve1(), 10_000e18);
    }
    function test_AddLiquidity_MintLP() public {
        _addLiquidity(alice, 10_000e18, 10_000e18);
        assertGt(amm.lpToken().balanceOf(alice), 0);
    }
    function test_RemoveLiquidity() public {
        uint256 lp = _addLiquidity(alice, 10_000e18, 10_000e18);
        vm.startPrank(alice);
        amm.lpToken().approve(address(amm), lp);
        (uint256 a0, uint256 a1) = amm.removeLiquidity(lp, 0, 0);
        vm.stopPrank();
        assertGt(a0, 0); assertGt(a1, 0);
    }
    function test_Swap_AforB() public {
        _addLiquidity(alice, 10_000e18, 10_000e18);
        uint256 preview = amm.getAmountOut(address(tokenA), 100e18);
        vm.startPrank(bob);
        tokenA.approve(address(amm), 100e18);
        uint256 out = amm.swap(address(tokenA), 100e18, 0);
        vm.stopPrank();
        assertEq(out, preview);
    }
    function test_Swap_BforA() public {
        _addLiquidity(alice, 10_000e18, 10_000e18);
        tokenB.transfer(bob, 100e18);
        vm.startPrank(bob);
        tokenB.approve(address(amm), 100e18);
        uint256 out = amm.swap(address(tokenB), 100e18, 0);
        vm.stopPrank();
        assertGt(out, 0);
    }
    function test_Swap_FeeApplied() public {
        _addLiquidity(alice, 10_000e18, 10_000e18);
        uint256 out = amm.getAmountOut(address(tokenA), 1_000e18);
        assertLt(out, 1_000e18);
    }
    function test_KInvariant_AfterSwap() public {
        _addLiquidity(alice, 10_000e18, 10_000e18);
        uint256 kBefore = amm.reserve0() * amm.reserve1();
        vm.startPrank(bob);
        tokenA.approve(address(amm), 100e18);
        amm.swap(address(tokenA), 100e18, 0);
        vm.stopPrank();
        assertGe(amm.reserve0() * amm.reserve1(), kBefore);
    }
    function test_RevertSwap_Slippage() public {
        _addLiquidity(alice, 10_000e18, 10_000e18);
        vm.startPrank(bob);
        tokenA.approve(address(amm), 100e18);
        vm.expectRevert("Slippage");
        amm.swap(address(tokenA), 100e18, type(uint256).max);
        vm.stopPrank();
    }
    function test_RevertSwap_BadToken() public {
        _addLiquidity(alice, 10_000e18, 10_000e18);
        vm.expectRevert("Bad token");
        amm.swap(address(0x1), 100e18, 0);
    }
    function test_RevertAddLiquidity_Slippage() public {
        _addLiquidity(alice, 10_000e18, 10_000e18);
        vm.startPrank(alice);
        tokenA.approve(address(amm), 1_000e18);
        tokenB.approve(address(amm), 1_000e18);
        vm.expectRevert("Slippage");
        amm.addLiquidity(1_000e18, 1_000e18, type(uint256).max);
        vm.stopPrank();
    }
    function test_RevertConstructor_SameTokens() public {
        vm.expectRevert("Same tokens");
        new GameAMM(address(tokenA), address(tokenA));
    }
    function test_GetAmountOut_Symmetric() public {
        _addLiquidity(alice, 10_000e18, 10_000e18);
        assertEq(
            amm.getAmountOut(address(tokenA), 100e18),
            amm.getAmountOut(address(tokenB), 100e18)
        );
    }
    function test_ReservesUpdateAfterSwap() public {
        _addLiquidity(alice, 10_000e18, 10_000e18);
        uint256 r0Before = amm.reserve0();
        vm.startPrank(bob);
        tokenA.approve(address(amm), 100e18);
        amm.swap(address(tokenA), 100e18, 0);
        vm.stopPrank();
        assertGt(amm.reserve0(), r0Before);
    }

    // Fuzz
    function testFuzz_Swap(uint256 amtIn) public {
        _addLiquidity(alice, 100_000e18, 100_000e18);
        amtIn = bound(amtIn, 1e15, 1_000e18);
        tokenA.transfer(bob, amtIn);
        vm.startPrank(bob);
        tokenA.approve(address(amm), amtIn);
        uint256 out = amm.swap(address(tokenA), amtIn, 0);
        vm.stopPrank();
        assertGt(out, 0);
    }
    function testFuzz_KInvariant(uint256 amtIn) public {
        _addLiquidity(alice, 50_000e18, 50_000e18);
        amtIn = bound(amtIn, 1e15, 5_000e18);
        uint256 kBefore = amm.reserve0() * amm.reserve1();
        tokenA.transfer(bob, amtIn);
        vm.startPrank(bob);
        tokenA.approve(address(amm), amtIn);
        amm.swap(address(tokenA), amtIn, 0);
        vm.stopPrank();
        assertGe(amm.reserve0() * amm.reserve1(), kBefore);
    }
    function testFuzz_AddRemoveLiquidity(uint256 amount) public {
        amount = bound(amount, 1_001, 50_000e18);
        tokenA.approve(address(amm), amount);
        tokenB.approve(address(amm), amount);
        uint256 lp = amm.addLiquidity(amount, amount, 0);
        amm.lpToken().approve(address(amm), lp);
        (uint256 a0, uint256 a1) = amm.removeLiquidity(lp, 0, 0);
        assertGt(a0, 0); assertGt(a1, 0);
    }
    function testFuzz_GetAmountOut(uint256 amtIn) public {
        _addLiquidity(alice, 10_000e18, 10_000e18);
        amtIn = bound(amtIn, 1e6, 1_000e18);
        assertGt(amm.getAmountOut(address(tokenA), amtIn), 0);
    }

    function _addLiquidity(address user, uint256 a0, uint256 a1) internal returns (uint256 lp) {
        vm.startPrank(user);
        tokenA.approve(address(amm), a0);
        tokenB.approve(address(amm), a1);
        lp = amm.addLiquidity(a0, a1, 0);
        vm.stopPrank();
    }
}