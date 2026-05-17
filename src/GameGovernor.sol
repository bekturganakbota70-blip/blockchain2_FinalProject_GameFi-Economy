// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";

contract GameGovernor is Governor, GovernorSettings, GovernorCountingSimple,
    GovernorVotes, GovernorVotesQuorumFraction, GovernorTimelockControl
{
    constructor(IVotes _token, TimelockController _timelock)
        Governor("GameFi Governor")
        GovernorSettings(1 days, 1 weeks, 100_000e18)
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4)
        GovernorTimelockControl(_timelock)
    {}

    function votingDelay() public view override(Governor, GovernorSettings) returns (uint256) { return super.votingDelay(); }
    function votingPeriod() public view override(Governor, GovernorSettings) returns (uint256) { return super.votingPeriod(); }
    function proposalThreshold() public view override(Governor, GovernorSettings) returns (uint256) { return super.proposalThreshold(); }
    function quorum(uint256 b) public view override(Governor, GovernorVotesQuorumFraction) returns (uint256) { return super.quorum(b); }
    function state(uint256 id) public view override(Governor, GovernorTimelockControl) returns (ProposalState) { return super.state(id); }
    function proposalNeedsQueuing(uint256 id) public view override(Governor, GovernorTimelockControl) returns (bool) { return super.proposalNeedsQueuing(id); }
    function _queueOperations(uint256 id, address[] memory t, uint256[] memory v, bytes[] memory c, bytes32 dh) internal override(Governor, GovernorTimelockControl) returns (uint48) { return super._queueOperations(id, t, v, c, dh); }
    function _executeOperations(uint256 id, address[] memory t, uint256[] memory v, bytes[] memory c, bytes32 dh) internal override(Governor, GovernorTimelockControl) { super._executeOperations(id, t, v, c, dh); }
    function _cancel(address[] memory t, uint256[] memory v, bytes[] memory c, bytes32 dh) internal override(Governor, GovernorTimelockControl) returns (uint256) { return super._cancel(t, v, c, dh); }
    function _executor() internal view override(Governor, GovernorTimelockControl) returns (address) { return super._executor(); }
}