# Treasury Contract

This is a smart contract for managing a treasury that deposits funds into Uniswap and Aave. The contract allows the owner to set ratios for distribution between Uniswap and Aave, deposit USDC, and withdraw USDT and DAI.

## Features

- Deposit USDC into the contract
- Distribute deposited funds between Uniswap and Aave based on set ratios
- Swap USDC for USDT on Uniswap
- Deposit USDC into Aave and receive DAI
- Withdraw USDT and DAI from the contract
- Calculate the total yield of the treasury

## Dependencies

- OpenZeppelin Contracts: ERC20, SafeERC20, and Ownable
- Uniswap V2 Router02 Interface
- Aave Lending Pool Interface

## Constructor

The constructor takes the following parameters:

- `_uniswapRouter`: Address of the Uniswap V2 Router02 contract
- `_aaveLendingPool`: Address of the Aave Lending Pool contract
- `_usdcToken`: Address of the USDC token contract
- `_usdtToken`: Address of the USDT token contract
- `_daiToken`: Address of the DAI token contract

## Functions

### `setRatios(uint256 _uniswapRatio, uint256 _aaveRatio)`

Sets the distribution ratios for Uniswap and Aave. The sum of both ratios must equal 100.

### `deposit(uint256 amount)`

Deposits USDC into the contract and distributes the funds between Uniswap and Aave based on the set ratios. Swaps USDC for USDT on Uniswap and deposits USDC into Aave to receive DAI.

### `withdraw(uint256 amount)`

Withdraws USDT and DAI from the contract based on the set ratios.

### `calculateYield()`

Calculates the total yield of the treasury by adding the USDT and DAI balances.
