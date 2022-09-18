// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";


contract WrapperERC721 is ERC721, ERC721URIStorage  {  {
    address public immutable manager;
    IERC721Metadata public immutable nftContract;

    error IsNotManager(address caller);

    constructor(
        address _manager, 
        IERC721Metadata _nftContract
    ) ERC721(_nftContract.name(), _nftContract.symbol()) {
        manager =_manager;
        nftContract = _nftContract;
    }

    function getURI(uint256 tokenId) external view returns (string memory _uri) {
        _uri = nftContract.tokenURI(tokenId);
    }

    function mint(address to, uint256 tokenId) external onlyManager {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, nftContract.tokenURI(tokenId));
    }

    function burn(uint256 tokenId) external onlyManager {
        _burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        external
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory _uri)
    {
        _uri = super.tokenURI(tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    modifier onlyManager {
        if (msg.sender != manager) revert IsNotManager(msg.sender);
        _;
    }
}