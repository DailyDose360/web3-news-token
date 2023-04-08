# Web3 News Token
The Web3 News Token is a decentralized solution for rewarding content creators and consumers in the crypto news ecosystem. This project consists of a modular Ethereum-based ERC20 token implemented using Solidity smart contracts.

## Features
- Reward writers for contributing articles
- Reward readers for reading articles
- Reward users for sharing articles on social media
- Manage writers through an admin role

## Contracts
`Web3NewsTokenBase.sol`: The base contract containing data structures, events, and interfaces
`Web3NewsToken.sol`: The implementation contract containing the functions and logic

## Dependencies
[OpenZeppelin Contracts v4.3](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/release-v4.3).


## Setup
Install [Node.js](https://nodejs.org/) and [npm](https://www.npmjs.com/).
Install Truffle globally:
```
npm install -g truffle
```

Clone the repository:
```
git clone https://github.com/<your_username>/web3-news-token.git
cd web3-news-token
```

Install dependencies:
```
npm install
```

## Deployment
Configure your preferred Ethereum network (e.g., local development network, testnet, or mainnet) in the truffle-config.js file.
Compile the contracts:

```
truffle compile
```

Deploy the contracts:

```
truffle migrate --network <network_name>
```

## Testing
Run tests with Truffle:
```
truffle test
```

## Usage
Interact with the smart contracts using Truffle console:
```
truffle console --network <network_name>
```

Example usage:
```
// Import the contracts
const Web3NewsToken = artifacts.require('Web3NewsToken');

// Deploy the token
const reserveAddress = '0x...'; // Replace with a valid Ethereum address
const token = await Web3NewsToken.new(reserveAddress);

// Add a writer
const writer = '0x...'; // Replace with a valid Ethereum address
await token.addWriter(writer);

// Check if the writer is added
const isWriter = await token.writers(writer);
console.log(`Is writer? ${isWriter}`);
```

## Contributing
We welcome contributions and improvements! Please feel free to fork this repository, make changes, and submit pull requests.

## License
This project is licensed under the MIT License.
