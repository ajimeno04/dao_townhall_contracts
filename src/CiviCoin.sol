// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract CiviCoin is ERC20, Ownable {

    constructor() ERC20("CiviCoin", "CVC") Ownable(msg.sender) {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
