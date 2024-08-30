// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../lib/forge-std/src/Script.sol";
import "../src/CiviCoin.sol";
import "../src/TownHallDAO.sol";

contract Verify is Script {
    function run() external {
        // Fetch private keys from environment variables
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        uint256 testUserPrivateKey = vm.envUint("TEST_USER_PRIVATE_KEY");

        // Set up initial variables
        uint256 initialMint = 1000 * 10**18;
        uint256 proposalAmount = 1 ether; // 1 ETH for the proposal
        string memory proposalDescription = "Build a new park";
        address payable recipient = payable(vm.addr(testUserPrivateKey));

        // Start broadcasting transactions as deployer
        vm.startBroadcast(deployerPrivateKey);

        // Deploy CiviCoin contract
        CiviCoin civiCoin = new CiviCoin();

        // Deploy TownHallDAO contract
        TownHallDAO dao = new TownHallDAO(address(civiCoin));

        // Transfer ownership of CiviCoin to the TownHallDAO
        civiCoin.transferOwnership(address(dao));

        // Mint initial tokens to the test user via TownHallDAO
        dao.addUser(vm.addr(testUserPrivateKey), initialMint);

        // Fund the DAO with ETH to cover the proposal's execution
        payable(address(dao)).transfer(2 ether); // Transfer 2 ETH to the DAO

        vm.stopBroadcast();

        // Start broadcasting as the test user
        vm.startBroadcast(testUserPrivateKey);

        // Test creating a proposal as the test user
        dao.createProposal(proposalDescription, proposalAmount, recipient);

        // Test voting on the proposal
        uint256 proposalId = 1;
        uint256 voteAmount = 10 * 10**18; // 10 CiviCoins
        dao.voteOnProposal(proposalId, voteAmount, true); // Vote in favor

        vm.stopBroadcast();

        // // Advance time after all transactions are committed
        // vm.warp(block.timestamp + 1 weeks + 1);

        // // Execute the proposal
        // vm.startBroadcast(testUserPrivateKey);
        // dao.executeProposal(proposalId);
        // vm.stopBroadcast();
    }
}
