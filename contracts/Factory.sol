// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Factory is Ownable {
    address public immutable manager;

    constructor() {
        manager = msg.sender;
    }



    
}