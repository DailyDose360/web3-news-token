// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.3.3/contracts/token/ERC20/ERC20.sol";

abstract contract Web3NewsTokenBase is ERC20 {
    address public admin;
    uint256 public constant maxTokens = 50000000 * 10 ** 10; // Updated total supply
    uint256 public constant reservedTokens = 10000000 * 10 ** 10; // Updated reserved tokens

    event Contribute(address indexed writer, string article);
    event ReadArticle(address indexed reader);
    event ShareOnSocialMedia(address indexed sharer);
    event Tip(address indexed sender, address indexed recipient, uint256 amount);
    event ProjectDistribution(address indexed sender, address indexed projectAddress, uint256 amount);

    constructor(address reserveAddress, string memory name, string memory symbol) ERC20(name, symbol) {
        require(reserveAddress != address(0), "Invalid reserve address");
        _mint(msg.sender, maxTokens - reservedTokens);
        _mint(reserveAddress, reservedTokens);
        admin = msg.sender;
    }

    function decimals() public pure virtual override returns (uint8) {
        return 10;
    }
}

