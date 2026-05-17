// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

interface AggregatorV3Interface {
    function latestRoundData() external view returns (
        uint80, int256 answer, uint256, uint256 updatedAt, uint80
    );
}

contract GameItems is Initializable, ERC1155Upgradeable, AccessControlUpgradeable, UUPSUpgradeable {
    bytes32 public constant MINTER_ROLE   = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    uint256 public constant GOLD   = 1;
    uint256 public constant SWORD  = 2;
    uint256 public constant POTION = 3;

    AggregatorV3Interface public priceFeed;
    uint256 public constant STALENESS = 1 hours;

    mapping(uint256 => uint256) public itemPriceUsd;
    mapping(uint256 => uint256) public craftCostGold;

    event ItemBought(address indexed buyer, uint256 itemId, uint256 amount);
    event ItemCrafted(address indexed player, uint256 itemId, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() { _disableInitializers(); }

    function initialize(address admin, address _priceFeed) public initializer {
    __ERC1155_init("https://api.gamefi.xyz/items/{id}.json");
    __AccessControl_init();

    _grantRole(DEFAULT_ADMIN_ROLE, admin);
    _grantRole(MINTER_ROLE, admin);
    _grantRole(UPGRADER_ROLE, admin);

    priceFeed = AggregatorV3Interface(_priceFeed);

    itemPriceUsd[GOLD]   = 1e8;
    itemPriceUsd[SWORD]  = 5e8;
    itemPriceUsd[POTION] = 2e8;

    craftCostGold[SWORD]  = 10;
    craftCostGold[POTION] = 5;
}

    function buyItem(uint256 itemId, uint256 amount) external payable {
        require(itemPriceUsd[itemId] > 0, "Not for sale");
        (, int256 price, , uint256 updatedAt, ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price");
        require(block.timestamp - updatedAt <= STALENESS, "Stale price");

        uint256 ethNeeded = (itemPriceUsd[itemId] * amount * 1e18) / uint256(price);
        require(msg.value >= ethNeeded, "Insufficient ETH");
        _mint(msg.sender, itemId, amount, "");

        uint256 excess = msg.value - ethNeeded;
        if (excess > 0) {
            (bool ok, ) = payable(msg.sender).call{value: excess}("");
            require(ok, "Refund failed");
        }
        emit ItemBought(msg.sender, itemId, amount);
    }

    function craft(uint256 itemId, uint256 amount) external {
        uint256 cost = craftCostGold[itemId] * amount;
        require(cost > 0, "Not craftable");
        _burn(msg.sender, GOLD, cost);
        _mint(msg.sender, itemId, amount, "");
        emit ItemCrafted(msg.sender, itemId, amount);
    }

    function mint(address to, uint256 id, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, id, amount, "");
    }

    function burn(address from, uint256 id, uint256 amount) external onlyRole(MINTER_ROLE) {
        _burn(from, id, amount);
    }

    function setCraftCost(uint256 itemId, uint256 cost) external onlyRole(DEFAULT_ADMIN_ROLE) {
        craftCostGold[itemId] = cost;
    }

    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) {}

    function supportsInterface(bytes4 interfaceId)
        public view override(ERC1155Upgradeable, AccessControlUpgradeable) returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}