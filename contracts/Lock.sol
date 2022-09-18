// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Lock is ERC1155Holder, ERC721Holder {
    using EnumerableSet for EnumerableSet.UintSet;

    address public immutable manager;

    struct StakeInfo {
        address owner;
        uint256 amount;
        uint256 lockTime;
        uint256 lockDuration;
    }

    /// Maps the NFT Contract to the NFT ID to the Staking Informations 
    mapping(address => mapping(uint256 => StakeInfo)) public stakeInfoByContractAddress;
    /// Maps the wallet address to the NFT Contract to the NFT IDs owned by the wallet
    mapping(address => mapping(address => UintSet)) public stakeInfoByOwner;

    error IsNotManager(address caller);
    error IsNotNftOwner(address caller);
    error AmountTooHigh(uint256 amount, uint256 maxAmount);

    constructor() {
        manager = msg.sender;
    }

    function stakeERC721Assets external (
        IERC721 _nftContract,
        uint256[] calldata _tokenIds,
        uint256 _lockDuration
    ) {
        for (uint256 i = 0; i < _tokenIds.length; ++i) {
            _nftContract.safeTransferFrom(msg.sender, address(this), _tokenIds[i]);
            stakeInfoByContractAddress[_nftContract][_tokenIds[i]] = StakeInfo({
                owner: msg.sender,
                amount: 1,
                lockTime: block.timestamp,
                lockDuration: _lockDuration
            });
            stakeInfoByOwner[msg.sender][_nftContract].add(_tokenIds[i]);
        }
    }

    function stakeERC1155Assets external (
        IERC1155 _nftContract,
        uint256[] calldata _tokenIds,
        uint256[] calldata _amounts,
        uint256 _lockDuration
    ) {
        _nftContract.safeBatchTransferFrom(msg.sender, address(this), _tokenIds, _amounts, "");
        for (uint256 i = 0; i < _tokenIds.length; ++i) {
            stakeInfoByContractAddress[_nftContract][_tokenIds[i]] = StakeInfo({
                owner: msg.sender,
                amount: _amounts[i],
                lockTime: block.timestamp,
                lockDuration: _lockDuration
            });
            stakeInfoByOwner[msg.sender][_nftContract].add(_tokenIds[i]);
        }
    }

    function unstakeERC721Assets external (
        IERC721 _nftContract,
        uint256[] calldata _tokenIds
    ) {
        for (uint256 i = 0; i < _tokenIds.length; ++i) {
            if (stakeInfoByContractAddress[_nftContract][_tokenIds[i]].owner != msg.sender) {
                revert IsNotNftOwner(msg.sender);
            }
            _nftContract.safeTransferFrom(address(this), msg.sender, _tokenIds[i]);
            stakeInfoByContractAddress[_nftContract][_tokenIds[i]] = StakeInfo({
                owner: address(0),
                amount: 0,
                lockTime: 0,
                lockDuration: 0
            });
            stakeInfoByOwner[msg.sender][_nftContract].remove(_tokenIds[i]);
        }
    }

    function unstakeERC1155Assets external (
        IERC1155 _nftContract,
        uint256[] calldata _tokenIds,
        uint256[] calldata _amounts
    ) {
        for (uint256 i = 0; i < _tokenIds.length; ++i) {
            if (stakeInfoByContractAddress[_nftContract][_tokenIds[i]].owner != msg.sender) {
                revert IsNotNftOwner(msg.sender);
            }
            if (stakeInfoByContractAddress[_nftContract][_tokenIds[i]].amount < _amounts[i]) {
                revert AmountTooHigh(_amounts[i], stakeInfoByContractAddress[_nftContract][_tokenIds[i]].amount);
            }
            _nftContract.safeTransferFrom(address(this), msg.sender, _tokenIds[i], _amounts[i], "");
            if (stakeInfoByContractAddress[_nftContract][_tokenIds[i]].amount == _amounts[i]) {
                stakeInfoByContractAddress[_nftContract][_tokenIds[i]] = StakeInfo({
                    owner: address(0),
                    amount: 0,
                    lockTime: 0,
                    lockDuration: 0
                });
                stakeInfoByOwner[msg.sender][_nftContract].remove(_tokenIds[i]);
            } 
            else {
                stakeInfoByContractAddress[_nftContract][_tokenIds[i]].amount -= _amounts[i];
            }
        }
    }

    modifier onlyManager {
        if (msg.sender != manager) revert IsNotManager(msg.sender);
        _;
    }
}
