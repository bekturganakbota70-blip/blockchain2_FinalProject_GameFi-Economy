// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/governance/TimelockController.sol";
import "../src/GameGovernor.sol";
import "../src/GOV.sol";

contract GovernanceTest is Test {
    GameGovernor       governor;
    TimelockController timelock;
    GOV gov;
    address alice = makeAddr("alice");

    function setUp() public {
        gov = new GOV();

        address[] memory none = new address[](0);
        address[] memory exec = new address[](1);
        exec[0] = address(0);
        timelock = new TimelockController(2 days, none, exec, address(this));
        governor = new GameGovernor(gov, timelock);

        timelock.grantRole(timelock.PROPOSER_ROLE(),  address(governor));
        timelock.grantRole(timelock.CANCELLER_ROLE(), address(governor));
        timelock.renounceRole(timelock.DEFAULT_ADMIN_ROLE(), address(this));

        gov.transfer(alice, 200_000e18);
        vm.prank(alice); gov.delegate(alice);
        gov.delegate(address(this));
        vm.roll(block.number + 1);
    }

    function test_GovernorName()      public view { assertEq(governor.name(), "GameFi Governor"); }
    function test_VotingDelay()       public view { assertEq(governor.votingDelay(), 1 days); }
    function test_VotingPeriod()      public view { assertEq(governor.votingPeriod(), 1 weeks); }
    function test_ProposalThreshold() public view { assertEq(governor.proposalThreshold(), 100_000e18); }
    function test_QuorumPositive()    public view { assertGt(governor.quorum(block.number - 1), 0); }

    function test_FullLifecycle() public {
        // Proposal: DAO votes to change timelock delay from 2 days → 3 days
        address[] memory targets   = new address[](1);
        uint256[] memory values    = new uint256[](1);
        bytes[]   memory calldatas = new bytes[](1);

        targets[0]   = address(timelock);
        values[0]    = 0;
        calldatas[0] = abi.encodeCall(timelock.updateDelay, (3 days));
        string memory desc = "Change timelock delay to 3 days";

        // Alice proposes
        vm.prank(alice);
        uint256 pid = governor.propose(targets, values, calldatas, desc);

        // Advance past voting delay (1 day = 86400 blocks)
        vm.roll(block.number + 86401);

        // Alice votes For
        vm.prank(alice);
        governor.castVote(pid, 1);

        // Test contract votes For (~99.8M tokens → quorum met)
        governor.castVote(pid, 1);

        // Advance past voting period (1 week = 604800 blocks)
        vm.roll(block.number + 604801);

        assertEq(uint256(governor.state(pid)), 4); // Succeeded

        bytes32 descHash = keccak256(bytes(desc));
        governor.queue(targets, values, calldatas, descHash);
        assertEq(uint256(governor.state(pid)), 5); // Queued

        // Wait timelock delay (2 days in seconds)
        vm.warp(block.timestamp + 2 days + 1);

        // Execute — timelock calls itself to update delay
        governor.execute(targets, values, calldatas, descHash);
        assertEq(uint256(governor.state(pid)), 7); // Executed

        // Verify the change took effect
        assertEq(timelock.getMinDelay(), 3 days);
    }
}
