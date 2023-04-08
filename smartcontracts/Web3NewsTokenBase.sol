// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/token/ERC20/ERC20.sol";

abstract contract Web3NewsTokenBase is ERC20 {
    address public admin;
    mapping(address => bool) public writers;

    uint256 public constant maxTokens = 21000000 * 10 ** 10;
    uint256 public constant reservedTokens = 5000000 * 10 ** 10;

    event Contribute(address indexed writer, string article);
    event ReadArticle(address indexed reader);
    event ShareOnSocialMedia(address indexed sharer);

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

