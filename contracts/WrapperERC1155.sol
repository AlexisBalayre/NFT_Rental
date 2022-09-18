// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";

contract WrapperERC1155 is ERC1155, ERC1155URIStorage {
    address public immutable manager;
    IERC1155MetadataURI public immutable nftContract;

    error IsNotManager(address caller);

    constructor(
        address _manager, 
        IERC1155MetadataURI _nftContract
    ) ERC1155("") {
        manager =_manager;
        nftContract = _nftContract;
    }

    function getURI(uint256 tokenId) external view returns (string memory _uri) {
        _uri = nftContract.uri(tokenId);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        external
        onlyManager
    {
        _mint(account, id, amount, data);
        _setURI(tokenId, nftContract.uri(tokenId));
    }

    function burn(address account, uint256 id, uint256 amount)
        external
        onlyManager
    {
        _burn(account, id, amount);
    }

    modifier onlyManager {
        if (msg.sender != manager) revert IsNotManager(msg.sender);
        _;
    }

}