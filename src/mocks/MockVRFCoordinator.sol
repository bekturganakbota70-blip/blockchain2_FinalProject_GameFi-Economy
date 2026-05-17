// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IVRFConsumer {
    function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external;
}

contract MockVRFCoordinator {
    uint256 private _nextRequestId = 1;

    function requestRandomWords(bytes32, uint64, uint16, uint32, uint32)
        external returns (uint256)
    {
        return _nextRequestId++;
    }

    function fulfillRandomWords(address consumer, uint256 requestId, uint256[] calldata randomWords) external {
        IVRFConsumer(consumer).rawFulfillRandomWords(requestId, randomWords);
    }
}