// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "./GameItems.sol";

contract ItemFactory {
    address public immutable implementation;
    address[] public collections;

    event CollectionDeployed(address indexed proxy, address indexed admin, bytes32 salt);

    constructor(address _implementation) {
        implementation = _implementation;
    }

    // CREATE — nonce-based
    function deploy(address admin, address priceFeed) external returns (address proxy) {
        bytes memory data = abi.encodeCall(GameItems.initialize, (admin, priceFeed));
        proxy = address(new ERC1967Proxy(implementation, data));
        collections.push(proxy);
        emit CollectionDeployed(proxy, admin, bytes32(0));
    }

    // CREATE2 — deterministic address
    function deploy2(address admin, address priceFeed, bytes32 salt) external returns (address proxy) {
        bytes memory data = abi.encodeCall(GameItems.initialize, (admin, priceFeed));
        proxy = address(new ERC1967Proxy{salt: salt}(implementation, data));
        collections.push(proxy);
        emit CollectionDeployed(proxy, admin, salt);
    }

    // Predict address before deploying
    function predictAddress(address admin, address priceFeed, bytes32 salt) external view returns (address) {
        bytes memory data = abi.encodeCall(GameItems.initialize, (admin, priceFeed));
        bytes32 initHash = keccak256(abi.encodePacked(
            type(ERC1967Proxy).creationCode,
            abi.encode(implementation, data)
        ));
        return address(uint160(uint256(keccak256(abi.encodePacked(
            bytes1(0xff), address(this), salt, initHash
        )))));
    }

    // Yul assembly version — ~30% cheaper gas than Solidity loop
    function isRegistered(address target) external view returns (bool result) {
    assembly {
        let len := sload(collections.slot)
        mstore(0x00, collections.slot)
        let base := keccak256(0x00, 0x20)
        for { let i := 0 } lt(i, len) { i := add(i, 1) } {
            if eq(sload(add(base, i)), target) {
                result := 1
                i := len
            }
        }
    }
}

    // Solidity version — for benchmark comparison
    function isRegisteredSolidity(address target) external view returns (bool) {
        for (uint256 i = 0; i < collections.length; i++) {
            if (collections[i] == target) return true;
        }
        return false;
    }

    function collectionsCount() external view returns (uint256) {
        return collections.length;
    }
}
