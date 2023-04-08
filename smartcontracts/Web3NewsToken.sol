// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Web3NewsTokenBase.sol";

contract Web3NewsToken is Web3NewsTokenBase {
    // Minimum time intervals in seconds between function calls
    uint256 public constant contributeInterval = 86400; // 24 hours
    uint256 public constant readArticleInterval = 3600; // 1 hour
    uint256 public constant shareOnSocialMediaInterval = 7200; // 2 hours

    mapping(address => uint256) private lastContribution;
    mapping(address => uint256) private lastArticleRead;
    mapping(address => uint256) private lastSocialMediaShare;

    constructor(address reserveAddress) Web3NewsTokenBase(reserveAddress, "Web3NewsToken", "W3NT") {}

    // ... (other functions) ...

    function contribute(string memory article) public {
        require(writers[msg.sender] == true, "Only registered writers can contribute articles");
        require(block.timestamp - lastContribution[msg.sender] >= contributeInterval, "Minimum time interval not met for contribute");
        lastContribution[msg.sender] = block.timestamp;
        _contribute(msg.sender, article);
    }

    function readArticle() public {
        require(block.timestamp - lastArticleRead[msg.sender] >= readArticleInterval, "Minimum time interval not met for readArticle");
        lastArticleRead[msg.sender] = block.timestamp;
        _readArticle(msg.sender);
    }

    function shareOnSocialMedia() public {
        require(block.timestamp - lastSocialMediaShare[msg.sender] >= shareOnSocialMediaInterval, "Minimum time interval not met for shareOnSocialMedia");
        lastSocialMediaShare[msg.sender] = block.timestamp;
        _shareOnSocialMedia(msg.sender);
    }

    function _contribute(address writer, string memory article) internal {
        _mint(writer, 100 * (10 ** decimals()));
        emit Contribute(writer, article);
    }

    function _readArticle(address reader) internal {
        _mint(reader, 10 * (10 ** decimals()));
        emit ReadArticle(reader);
    }

    function _shareOnSocialMedia(address sharer) internal {
        _mint(sharer, 5 * (10 ** decimals()));
        emit ShareOnSocialMedia(sharer);
    }
}

