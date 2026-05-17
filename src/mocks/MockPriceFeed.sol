// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MockPriceFeed {
    int256  private _answer;
    uint256 private _updatedAt;

    constructor(int256 initialPrice) {
        _answer    = initialPrice;
        _updatedAt = block.timestamp;
    }

    function setPrice(int256 price) external { _answer = price; _updatedAt = block.timestamp; }
    function setUpdatedAt(uint256 ts) external { _updatedAt = ts; }

    function latestRoundData() external view returns (
        uint80, int256 answer, uint256, uint256 updatedAt, uint80
    ) {
        return (1, _answer, block.timestamp, _updatedAt, 1);
    }
}