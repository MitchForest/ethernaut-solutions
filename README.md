# Ethernaut Solutions

This repository contains solutions to the [Ethernaut](https://ethernaut.openzeppelin.com/) challenges, implemented using the [Foundry](https://book.getfoundry.sh/) framework.

Ethernaut is a Web3/Solidity-based game where each level is a smart contract that needs to be hacked. This repository provides:
- Local testing solutions
- Scripts for interacting with deployed instances
- Attack contracts for complex exploits
- Detailed explanations of vulnerabilities

## Setup

1. Clone this repository
```bash
git clone https://github.com/mitchforest/ethernaut-solutions.git
cd ethernaut-solutions
```

2. Install dependencies
```bash
forge install
```

3. Configure your environment
```bash
cp .env.example .env
```

Then edit the `.env` file to add your:
- Network RPC URL
- Player wallet address
- Private key (for sending transactions)
- Deployed instance addresses (from the Ethernaut UI)

## Repository Structure

```
├── docs/
│   └── challenge-writeups.md    # Detailed explanations of each vulnerability
├── script/
│   ├── DeployedSolver.s.sol     # Base script for solving deployed instances
│   ├── RunAll.s.sol             # Script to run multiple solutions sequentially
│   └── solutions/               # Scripts for solving deployed instances
├── src/
│   ├── attacks/                 # Contracts used to attack challenges
│   └── solutions/               # Local testing solutions
└── lib/
    └── ethernaut/               # Original Ethernaut challenge contracts
```

## Solving Challenges

### Local Testing (Simulation)

For local testing without deploying:

```bash
# Run a specific solution
forge test --match-contract FallbackSolution -vvv
```

### Working with Deployed Instances

After creating an instance on the Ethernaut website:

1. Add the instance address to your `.env` file
2. Run the solution script:

```bash
# To solve a specific challenge
forge script script/solutions/FallbackSolver.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast

# To solve multiple challenges at once
forge script script/RunAll.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast

# To solve a specific subset of challenges
SOLUTIONS=coinflip forge script script/RunAll.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

3. Return to the Ethernaut UI and click "Submit Instance" to verify

## Challenge Writeups

Check out `docs/challenge-writeups.md` for detailed explanations that include:
- Vulnerability description
- Exploit technique
- Real-world security implications
- Security lessons

## Completed Solutions

- [x] 01. Fallback - `src/solutions/Fallback.sol`
- [x] 02. CoinFlip - `src/solutions/CoinFlip.sol`
- [ ] 03. Fallout
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
- [ ] 30. MagicAnimalCarousel
- [ ] 31. Impersonator
- [ ] 32. HigherOrder
- [ ] 33. Stake

## Contributing

Feel free to contribute your own solutions by creating a pull request!
