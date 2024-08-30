// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../lib/forge-std/src/Script.sol";
import "../src/CiviCoin.sol";
import "../src/TownHallDAO.sol";

contract VerifyDeployment is Script {
    function run() external {
        // Get the deployer's private key from the environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions with the deployer's private key
        vm.startBroadcast(deployerPrivateKey);

        // Step 1: Deploy the CiviCoin contract
        CiviCoin civiCoin = new CiviCoin();

        // Step 2: Deploy the TownHallDAO contract with the address of CiviCoin
        TownHallDAO townHallDAO = new TownHallDAO(address(civiCoin));

        // Step 3: Test the addUser function
        // We use the deployer address as the test user
        address testUser = vm.addr(deployerPrivateKey);
        uint256 mintAmount = 1000 * 10 ** civiCoin.decimals();

        // Call addUser to mint tokens to the test user
        townHallDAO.addUser(testUser, mintAmount);

        // Log the user's balance to verify minting was successful
        uint256 userBalance = civiCoin.balanceOf(testUser);
        console.log("User Balance:", userBalance);

        // Check that the user was added
        bool userAdded = townHallDAO.isUser(testUser);
        console.log("User Added:", userAdded);

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
