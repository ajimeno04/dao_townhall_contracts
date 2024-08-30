// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CivicCoin is ERC20, Ownable {

    constructor() ERC20("CivicCoin", "CVC") {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}

contract TownHallDAO is Ownable {
    CivicCoin public civicCoin;

    mapping(address => bool) public isUser;

    event UserAdded(address indexed user, uint256 amount);

    constructor(address _civicCoinAddress) {
        civicCoin = CivicCoin(_civicCoinAddress);
    }

    function addUser(address user, uint256 amount) external onlyOwner {
        require(!isUser[user], "User already exists");

        civicCoin.mint(user, amount);

        isUser[user] = true;

        emit UserAdded(user, amount);
    }
}
