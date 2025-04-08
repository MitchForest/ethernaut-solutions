# Ethernaut Solutions

Solutions to [Ethernaut](https://ethernaut.openzeppelin.com/) challenges using [Foundry](https://book.getfoundry.sh/).

This repository contains my solutions to the Ethernaut smart contract security challenges, demonstrating various vulnerabilities and exploitation techniques. Each solution includes detailed explanations of the vulnerabilities and security lessons to take away.

## Getting Started

### Prerequisites
- [Foundry](https://getfoundry.sh/) installed
- A wallet with some Sepolia ETH for testing

### Setup

1. Clone and install dependencies
```bash
git clone https://github.com/mitchforest/ethernaut-solutions.git
cd ethernaut-solutions
forge install
```

2. Configure your environment
```bash
cp .env.example .env
# Add your private key (with 0x prefix) and RPC URL
```

## Understanding the Solutions

Each solution script in `script/solutions/` follows a consistent pattern:

1. **Direct interaction** with the vulnerable contract
2. **Step-by-step exploitation** with detailed comments
3. **Comprehensive explanation** of the vulnerability at the end of each file

To learn from a solution:
1. Read the vulnerability explanation at the bottom of the script
2. Follow the step-by-step exploitation in the `run()` function
3. Try to understand how each step contributes to the exploit

## Running Solutions Yourself

If you want to try the solutions against your own Ethernaut instances:

1. Create your own instance in the [Ethernaut UI](https://ethernaut.openzeppelin.com/)
2. Copy the solution script for the challenge you're working on
3. Update the instance address in the script
4. Run it with Foundry:

```bash
forge script script/solutions/ChallengeSolver.s.sol \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast
```

## Troubleshooting

- **Build issues**: Run `forge clean && forge build`
- **Transaction errors**: Use the `-vvv` flag for detailed output
- **Contract verification**: After running the solution, check in the Ethernaut UI if you've successfully completed the challenge

## Completed Solutions

- [x] 01. Fallback - `script/solutions/FallbackSolver.s.sol`
  - Exploits a flawed receive function to gain ownership
- [x] 02. Fallout - `script/solutions/FalloutSolver.s.sol`
  - Takes advantage of a typo in the constructor name
- [ ] 03. CoinFlip
- [ ] 04. Telephone
- [ ] 05. Token
- [ ] 06. Delegation
- [ ] 07. Force
- [ ] 08. Vault
- [ ] 09. King
- [ ] 10. Re-entrancy
- [ ] 11. Elevator
- [ ] 12. Privacy
- [ ] 13. GatekeeperOne
- [ ] 14. GatekeeperTwo
- [ ] 15. NaughtCoin
- [ ] 16. Preservation
- [ ] 17. Recovery
- [ ] 18. MagicNumber
- [ ] 19. AlienCodex
- [ ] 20. Denial
- [ ] 21. Shop
- [ ] 22. Dex
- [ ] 23. DexTwo
- [ ] 24. PuzzleWallet
- [ ] 25. Motorbike
- [ ] 26. DoubleEntryPoint
- [ ] 27. GoodSamaritan
- [ ] 28. GatekeeperThree
- [ ] 29. Switch
- [ ] 30. HigherOrder
- [ ] 31. Stake
- [ ] 32. Impersonator
- [ ] 33. MagicAnimalCarousel

## Security Lessons

These challenges demonstrate important security concepts including:
- Access control vulnerabilities
- Improper initialization
- Arithmetic issues
- Reentrancy
- Front-running
- And many more

Each solution script contains specific security takeaways relevant to that challenge.
