// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "./CiviCoin.sol";

contract TownHallDAO is Ownable {
    CiviCoin public civiCoinToken;

    mapping(address => bool) public isUser;

    event UserAdded(address indexed user, uint256 amount);

    // Constructor to set the CiviCoin contract address and the owner
    constructor(address _civiCoinAddress) Ownable(msg.sender) {
        civiCoinToken = CiviCoin(_civiCoinAddress);
    }

    function addUser(address user, uint256 amount) external onlyOwner {
        require(!isUser[user], "User already exists");

        civiCoinToken.mint(user, amount);

        isUser[user] = true;

        emit UserAdded(user, amount);
    }
}
