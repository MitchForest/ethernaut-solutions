// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

/**
 * @title DeployedSolverBase
 * @notice Base script for interacting with deployed Ethernaut instances
 * @dev Extend this contract to create solution scripts for each challenge
 */
abstract contract DeployedSolverBase is Script {
    // Environment variables
    string public network;
    address public playerAddress;
    string public rpcUrl;
    
    constructor() {
        // Load environment variables
        network = vm.envString("NETWORK");
        playerAddress = vm.envAddress("PLAYER_ADDRESS");
        rpcUrl = vm.envString("RPC_URL");
    }
    
    // Base setup method to be called in the beginning of each solution script
    function setUp() public virtual {
        // Fork the network to interact with deployed instances
        uint256 forkId = vm.createFork(rpcUrl);
        vm.selectFork(forkId);
        
        // Set the caller to be the player's address
        vm.startPrank(playerAddress);
    }
    
    // Helper function to log success
    function logSuccess() internal view {
        console.log("Challenge completed successfully!");
        console.log("Player address: %s", playerAddress);
    }
} 