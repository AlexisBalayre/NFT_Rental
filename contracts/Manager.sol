// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./Factory.sol";


contract Manager is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private nftContracts;
    Factory public immutable factory;
    Lock public immutable lock;

    constructor( {
        factory = new Factory();
        lock = new Lock();
    }

    function addNFTContract(address _nftContract) external onlyOwner {
        nftContracts.add(_nftContract);
    }

    function removeNFTContract(address _nftContract) external onlyOwner {
        nftContracts.remove(_nftContract);
    }

    function isWrapped(address _nftContract) public view returns (bool _isWrapped) {
        _isWrapped = nftContracts.contains(_nftContract);
    }
}