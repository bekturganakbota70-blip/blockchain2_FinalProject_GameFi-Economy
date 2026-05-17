// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../src/GameAMM.sol";
import "../src/GOV.sol";
import "../src/RentalVault.sol";

contract TokenB is ERC20 {
    constructor() ERC20("B","B") { _mint(msg.sender, 10_000_000e18); }
}

contract AMMHandler is Test {
    GameAMM amm; GOV t0; TokenB t1;

    constructor(GameAMM _a, GOV _t0, TokenB _t1) {
        amm = _a; t0 = _t0; t1 = _t1;
    }

    function swap(uint256 amt) external {
        if (amm.reserve0() == 0) return;
        amt = bound(amt, 1e15, 500e18);
        uint256 bal = t0.balanceOf(address(this));
        if (bal < amt) return;
        t0.approve(address(amm), amt);
        amm.swap(address(t0), amt, 0);
    }
}

contract AMMInvariantTest is Test {
    GameAMM amm; GOV t0; TokenB t1; AMMHandler handler;

    function setUp() public {
        t0 = new GOV(); t1 = new TokenB();
        amm = new GameAMM(address(t0), address(t1));
        handler = new AMMHandler(amm, t0, t1);

        // Add initial liquidity from test contract
        t0.approve(address(amm), 50_000e18);
        t1.approve(address(amm), 50_000e18);
        amm.addLiquidity(50_000e18, 50_000e18, 0);

        // Give handler tokens to swap with
        t0.transfer(address(handler), 10_000e18);

        targetContract(address(handler));
    }

    function invariant_KNeverDecreases() public view {
        assertGe(amm.reserve0() * amm.reserve1(), 40_000e18 * 40_000e18);
    }
    function invariant_ReservesMatchBalances() public view {
        assertEq(amm.reserve0(), t0.balanceOf(address(amm)));
        assertEq(amm.reserve1(), t1.balanceOf(address(amm)));
    }
    function invariant_LPSupplyPositive() public view {
        if (amm.reserve0() > 0) assertGt(amm.lpToken().totalSupply(), 0);
    }
}