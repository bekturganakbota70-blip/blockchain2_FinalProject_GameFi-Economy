// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";

interface IVRFCoordinatorV2 {
    function requestRandomWords(
        bytes32 keyHash, uint64 subId, uint16 minConfirmations,
        uint32 callbackGasLimit, uint32 numWords
    ) external returns (uint256 requestId);
}

interface IGameItems {
    function mint(address to, uint256 id, uint256 amount) external;
    function burn(address from, uint256 id, uint256 amount) external;
}

abstract contract VRFConsumerBase {
    IVRFCoordinatorV2 internal immutable COORDINATOR;
    constructor(address coordinator) { COORDINATOR = IVRFCoordinatorV2(coordinator); }
    function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
        require(msg.sender == address(COORDINATOR), "Only VRF coordinator");
        fulfillRandomWords(requestId, randomWords);
    }
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;
}

contract LootBox is VRFConsumerBase, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    IGameItems public immutable items;
    bytes32 public keyHash;
    uint64  public subscriptionId;
    uint32  public constant CALLBACK_GAS = 200_000;
    uint16  public constant MIN_CONFIRMS = 3;
    uint256 public constant GOLD_COST    = 5;

    uint256 private constant GOLD   = 1;
    uint256 private constant SWORD  = 2;
    uint256 private constant POTION = 3;

    mapping(uint256 => address) public pendingRequests;

    event BoxOpened(address indexed player, uint256 requestId);
    event LootDropped(address indexed player, uint256 itemId, uint256 amount);

    constructor(address coordinator, address _items, bytes32 _keyHash, uint64 _subId)
        VRFConsumerBase(coordinator)
    {
        items = IGameItems(_items);
        keyHash = _keyHash;
        subscriptionId = _subId;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    function openBox() external returns (uint256 requestId) {
        items.burn(msg.sender, GOLD, GOLD_COST);
        requestId = COORDINATOR.requestRandomWords(keyHash, subscriptionId, MIN_CONFIRMS, CALLBACK_GAS, 1);
        pendingRequests[requestId] = msg.sender;
        emit BoxOpened(msg.sender, requestId);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        address player = pendingRequests[requestId];
        delete pendingRequests[requestId];
        uint256 roll = randomWords[0] % 100;
        uint256 itemId; uint256 amount;
        if      (roll < 60) { itemId = POTION; amount = 3;  }
        else if (roll < 90) { itemId = SWORD;  amount = 1;  }
        else                { itemId = GOLD;   amount = 20; }
        items.mint(player, itemId, amount);
        emit LootDropped(player, itemId, amount);
    }

    function setKeyHash(bytes32 _kh) external onlyRole(ADMIN_ROLE) { keyHash = _kh; }
    function setSubId(uint64 _id)    external onlyRole(ADMIN_ROLE) { subscriptionId = _id; }
}