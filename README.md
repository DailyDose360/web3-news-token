# Web3News Token
This is a set of Solidity smart contracts for the Web3News token (W3NT). The token is an ERC20 token with additional functionality for rewarding writers, readers, and social media sharers of news articles. It also includes vesting contracts for team members and advisors.

## Contracts
The project contains the following contracts:

`Web3NewsTokenBase.sol`: A base contract containing the basic ERC20 token functionality and some constants used throughout the project.
`Web3NewsToken.sol`: The main token contract. It inherits from Web3NewsTokenBase.sol and adds functionality for rewarding writers, readers, and social media sharers.
`Staking.sol`: A contract for staking W3NT tokens and earning rewards.
`TokenVesting.sol`: A contract for vesting W3NT tokens for team members and advisors.

## Usage
To use the contracts, first compile them using Solidity compiler. The project uses Solidity version 0.8.18, so make sure to use a compatible compiler.

Once the contracts are compiled, you can deploy them to a blockchain network of your choice. The Web3NewsToken.sol contract should be deployed first, and the Staking.sol and TokenVesting.sol contracts can be deployed as needed.

To interact with the contracts, you can use any Ethereum wallet or blockchain explorer that supports smart contract interactions. The Web3NewsToken.sol contract exposes several public functions for rewarding writers, readers, and social media sharers, as well as for tipping and distributing tokens to projects.

The Staking.sol contract allows users to stake W3NT tokens and earn rewards based on a fixed reward rate per epoch. The TokenVesting.sol contract allows for vesting W3NT tokens for team members and advisors over a specified duration.

## License
The project is licensed under the MIT license. See the LICENSE file for details.
