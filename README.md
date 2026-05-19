# Mini Uniswap Liquidity Manager

A production-inspired DeFi liquidity and swap management protocol built with Solidity and Foundry.

This project demonstrates advanced smart contract engineering concepts including:

- Uniswap-style liquidity management
- Multi-hop token swaps
- Slippage protection
- Permit-based approvals (EIP-2612)
- Fuzz testing
- Invariant testing
- Fork testing
- Gas optimization
- Secure ERC20 handling
- Protocol pause mechanisms
- Reentrancy protection

---

# Overview

Mini Uniswap Liquidity Manager is a portfolio-grade DeFi project designed to simulate real-world decentralized exchange integrations and liquidity workflows.

The protocol allows users to:

- Add liquidity to token pairs
- Execute token swaps
- Use slippage-protected swaps
- Use signature-based permit approvals
- Interact with router-based AMM systems

This repository was built to demonstrate production-level Solidity engineering practices and advanced DeFi architecture patterns.

---

# Features

## Liquidity Management

- Add liquidity to token pairs
- Automatic refund of unused tokens ("dust")
- Secure router approvals
- Liquidity analytics tracking

## Token Swaps

- Multi-hop swap routing
- Slippage protection using basis points
- Expected output validation
- Gas-optimized swap execution

## Permit Support (EIP-2612)

- Gasless token approvals
- Signature-based swap authorization
- Improved DeFi UX patterns

## Security

- Reentrancy protection
- Emergency pause system
- Input validation
- Secure approval resets
- Deadline enforcement
- Custom Solidity errors

## Testing

- Unit tests
- Fuzz tests
- Invariant tests
- Fork tests

---

# Project Structure

```bash
src/
├── interfaces/
│   ├── IERC20Permit.sol
│   ├── IRouter.sol
│   └── IUniswapV2Router02.sol
│
├── libraries/
│   └── SlippageLib.sol
│
├── utils/
│   └── QuoteManager.sol
│
├── MiniLiquidityManager.sol
│
test/
├── unit/
├── fuzz/
├── invariant/
└── fork/
```

---

# Smart Contract Architecture

## Main Contract

### `MiniLiquidityManager.sol`

Core protocol contract responsible for:

- liquidity operations
- token swaps
- permit-based approvals
- router integrations
- analytics tracking
- protocol security

---

## Libraries

### `SlippageLib.sol`

Utility library for:

- slippage calculations
- basis point math
- minimum output protections

---

## Interfaces

### `IRouter.sol`

Minimal AMM router interface abstraction.

### `IERC20Permit.sol`

EIP-2612 permit interface.

### `IUniswapV2Router02.sol`

Quote and path utilities.

---

# Security Features

## Reentrancy Protection

Uses OpenZeppelin `ReentrancyGuard`.

## Emergency Pause

Protocol owner can pause critical operations during emergencies.

## Secure ERC20 Handling

Uses OpenZeppelin `SafeERC20`.

## Slippage Protection

Prevents excessive execution loss during swaps.

## Deadline Validation

Protects users against stale transactions.

## Approval Resetting

Router approvals are reset after execution.

---

# Testing Suite

This project includes multiple testing methodologies commonly used in professional DeFi protocols.

## Unit Tests

Tests core functionality and edge cases.

```bash
forge test
```

---

## Fuzz Testing

Randomized input testing for protocol robustness.

```bash
forge test --match-path test/fuzz/*
```

---

## Invariant Testing

Ensures protocol invariants remain valid under random operations.

```bash
forge test --match-path test/invariant/*
```

---

## Fork Testing

Tests protocol behavior against real blockchain state.

```bash
forge test --match-path test/fork/*
```

---

# Installation

## Clone Repository

```bash
git clone <YOUR_REPOSITORY_URL>
cd mini-uniswap-liquidity-manager
```

---

## Install Dependencies

```bash
forge install
```

---

## Build

```bash
forge build
```

---

## Run Tests

```bash
forge test -vv
```

---

# Gas Optimization

This project includes several gas optimization techniques:

- custom Solidity errors
- immutable variables
- unchecked arithmetic
- calldata usage
- approval reset strategy
- optimized storage patterns
- via-ir compilation

---

# Example Workflow

## Add Liquidity

```solidity
manager.addLiquidity(
    tokenA,
    tokenB,
    amountA,
    amountB,
    amountAMin,
    amountBMin,
    deadline
);
```

---

## Swap Tokens

```solidity
manager.swapExactInput(
    amountIn,
    expectedAmountOut,
    slippageBps,
    path,
    deadline
);
```

---

## Permit + Swap

```solidity
manager.permitAndSwap(
    token,
    amount,
    permitDeadline,
    v,
    r,
    s,
    expectedAmountOut,
    slippageBps,
    path,
    swapDeadline
);
```

---

# Tech Stack

- Solidity `0.8.24`
- Foundry
- OpenZeppelin Contracts
- Uniswap-style Router Architecture

---

# Production Concepts Demonstrated

This project demonstrates concepts used in modern DeFi systems:

- AMM router integrations
- liquidity provisioning
- swap routing
- slippage management
- EIP-2612 permits
- protocol pausing
- invariant testing
- fuzz testing
- secure token handling
- gas optimization

---

# Future Improvements

Planned upgrades:

- Uniswap V3 integration
- Concentrated liquidity
- Permit2 support
- TWAP oracles
- MEV protection
- Universal Router support
- Frontend dashboard
- Wagmi/Viem integration
- Multicall batching
- Advanced analytics

---

# Why This Project Exists

This repository was built as a portfolio-grade DeFi engineering project to demonstrate practical blockchain development skills beyond simple ERC20 contracts.

The goal is to showcase:

- secure Solidity engineering
- DeFi protocol architecture
- testing methodologies
- production-oriented design patterns

---

# Author

Yaghoub Adelzadeh
Blockchain Engineer

GitHub
[https://github.com/dappteacher](https://github.com/dappteacher)

---

# License

MIT License

---
