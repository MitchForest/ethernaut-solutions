// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "./solutions/FallbackSolver.s.sol";
import "./solutions/CoinFlipSolver.s.sol";
// Import additional solvers as they are implemented

/**
 * @title RunAllSolutions
 * @notice A script to run solutions for multiple Ethernaut challenges
 * @dev Run with: forge script script/RunAll.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY
 */
contract RunAllSolutions is Script {
    function run() public {
        // Get the solutions to run from environment variable or run all by default
        string memory solutionsToRun = vm.envOr("SOLUTIONS", string("all"));
        
        // Use keccak256 for string comparison
        bytes32 solutionsHash = keccak256(abi.encodePacked(solutionsToRun));
        bytes32 allHash = keccak256(abi.encodePacked("all"));
        bytes32 fallbackHash = keccak256(abi.encodePacked("fallback"));
        bytes32 coinFlipHash = keccak256(abi.encodePacked("coinflip"));
        
        if (solutionsHash == allHash || solutionsHash == fallbackHash) {
            console.log("\n=== RUNNING FALLBACK SOLUTION ===");
            FallbackSolver fallbackSolver = new FallbackSolver();
            fallbackSolver.run();
        }
        
        if (solutionsHash == allHash || solutionsHash == coinFlipHash) {
            console.log("\n=== RUNNING COINFLIP SOLUTION ===");
            CoinFlipSolver coinFlipSolver = new CoinFlipSolver();
            coinFlipSolver.run();
        }
        
        // Add additional solutions as they are implemented
        
        console.log("\n=== ALL REQUESTED SOLUTIONS COMPLETED ===");
    }
} 