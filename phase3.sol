// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract ProductMetadata is AccessControl {
    bytes32 public constant REGULATOR_ROLE = keccak256("REGULATOR_ROLE");

    // Mapping: Product ID → Encrypted metadata (IPFS CID)
    mapping(uint256 => string) private _encryptedMetadata;

    // Events
    event MetadataStored(uint256 indexed productId, string ipfsHash);
    event MetadataAudited(uint256 indexed productId, string ipfsHash);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /// -------- Store metadata --------
    function storeMetadata(uint256 productId, string memory ipfsHash) external {
        _encryptedMetadata[productId] = ipfsHash;
        emit MetadataStored(productId, ipfsHash);
    }

    /// -------- Regulator audit --------
    function auditMetadata(uint256 productId)
        external
        view
        onlyRole(REGULATOR_ROLE)
        returns (string memory)
    {
        return _encryptedMetadata[productId];
    }
}
