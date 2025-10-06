// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ProductRegistry is ERC721URIStorage, AccessControl {
    // ---- Roles ----
    bytes32 public constant MANUFACTURER_ROLE = keccak256("MANUFACTURER_ROLE");
    bytes32 public constant DISTRIBUTOR_ROLE  = keccak256("DISTRIBUTOR_ROLE");
    bytes32 public constant DISPENSER_ROLE    = keccak256("DISPENSER_ROLE");
    bytes32 public constant REGULATOR_ROLE    = keccak256("REGULATOR_ROLE");

    // ---- State ----
    uint256 private _tokenIds;

    // ---- Events ----
    event ProductMinted(uint256 indexed tokenId, address indexed manufacturer);
    event ProductTransferred(uint256 indexed tokenId, address indexed from, address indexed to);

    constructor() ERC721("SupplyChainProduct", "SCP") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender); // Deployer is admin
    }

    /// -------- Manufacturer: Mint new product --------
    function mintProduct(address to, string memory tokenURI)
        external
        onlyRole(MANUFACTURER_ROLE)
        returns (uint256)
    {
        _tokenIds++;
        uint256 newProductId = _tokenIds;

        _safeMint(to, newProductId);
        _setTokenURI(newProductId, tokenURI);

        emit ProductMinted(newProductId, msg.sender);
        return newProductId;
    }

    /// -------- Transfer single product --------
    function transferProduct(address to, uint256 tokenId) external {
        require(
            msg.sender == ownerOf(tokenId) ||
            getApproved(tokenId) == msg.sender ||
            isApprovedForAll(ownerOf(tokenId), msg.sender),
            "Not owner or approved"
        );

        _transfer(msg.sender, to, tokenId);
        emit ProductTransferred(tokenId, msg.sender, to);
    }

    /// -------- Batch transfer (Distributor only) --------
    function batchTransfer(address to, uint256[] calldata tokenIds)
        external
        onlyRole(DISTRIBUTOR_ROLE)
    {
        for (uint i = 0; i < tokenIds.length; i++) {
            require(
                msg.sender == ownerOf(tokenIds[i]) ||
                getApproved(tokenIds[i]) == msg.sender ||
                isApprovedForAll(ownerOf(tokenIds[i]), msg.sender),
                "Not owner or approved"
            );
            _transfer(msg.sender, to, tokenIds[i]);
            emit ProductTransferred(tokenIds[i], msg.sender, to);
        }
    }

    /// -------- Utility --------
    function getProductOwner(uint256 tokenId) external view returns (address) {
        return ownerOf(tokenId);
    }

    /// -------- Interface Support Override (Fixes Multiple Inheritance Error) --------
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
