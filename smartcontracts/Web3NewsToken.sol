// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Web3NewsTokenBase.sol";
import "./TokenVesting.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol";

contract Web3NewsToken is Web3NewsTokenBase, AccessControl {
    // Minimum time intervals in seconds between function calls
    uint256 public constant contributeInterval = 86400; // 24 hours
    uint256 public constant readArticleInterval = 3600; // 1 hour
    uint256 public constant shareOnSocialMediaInterval = 7200; // 2 hours

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(address => uint256) private lastContribution;
    mapping(address => uint256) private lastArticleRead;
    mapping(address => uint256) private lastSocialMediaShare;

    // Declare the roles mapping
    mapping(address => bool) public writers;

    // Deflationary Mechanisms
    uint256 public burnRate = 100; // 1% of the transaction amount will be burnt
    uint256 public feeRate = 50; // 0.5% of the transaction amount will be charged as a fee

    constructor(address reserveAddress) Web3NewsTokenBase(reserveAddress, "Web3NewsToken", "W3NT") {
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender); // Set up the Minter role for the deployer initially
    }

    function createVesting(
        address beneficiary,
        uint256 vestingStartTime,
        uint256 vestingDuration,
        uint256 vestingCliffDuration,
        uint256 amount
    ) public onlyRole(ADMIN_ROLE) returns (address) {
        TokenVesting tokenVesting = new TokenVesting(
            IERC20(address(this)),
            beneficiary,
            vestingStartTime,
            vestingDuration,
            vestingCliffDuration
        );

        _transfer(msg.sender, address(tokenVesting), amount);
        return address(tokenVesting);
    }

    function createVestingForTeamAndAdvisors(
        address[] memory beneficiaries,
        uint256[] memory vestingStartTimes,
        uint256[] memory vestingDurations,
        uint256[] memory vestingCliffDurations,
        uint256[] memory amounts
    ) public onlyRole(ADMIN_ROLE) {
        require(
            beneficiaries.length == vestingStartTimes.length &&
            beneficiaries.length == vestingDurations.length &&
            beneficiaries.length == vestingCliffDurations.length &&
            beneficiaries.length == amounts.length,
            "Input arrays must have the same length"
        );

        for (uint256 i = 0; i < beneficiaries.length; i++) {
            createVesting(
                beneficiaries[i],
                vestingStartTimes[i],
                vestingDurations[i],
                vestingCliffDurations[i],
                amounts[i]
            );
        }
    }

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
        _mint(writer, 200 * (10 ** decimals())); // Updated reward for contributing
        emit Contribute(writer, article);
    }

    function _readArticle(address reader) internal {
        _mint(reader, 15 * (10 ** decimals())); // Updated reward for reading articles
        emit ReadArticle(reader);
    }

    function _shareOnSocialMedia(address sharer) internal {
        _mint(sharer, 10 * (10 ** decimals())); // Updated reward for sharing on social media
        emit ShareOnSocialMedia(sharer);
    }

    function tip(address recipient, uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(writers[recipient] == true, "Recipient must be a registered writer");
        _transfer(msg.sender, recipient, amount);
        emit Tip(msg.sender, recipient, amount);
    }

    function distributeToProject(address projectAddress, uint256 amount) public onlyRole(ADMIN_ROLE) {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _transfer(msg.sender, projectAddress, amount);
        emit ProjectDistribution(msg.sender, projectAddress, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        uint256 burnAmount = (amount * burnRate) / 10000;
        uint256 feeAmount = (amount * feeRate) / 10000;
        uint256 netAmount = amount - burnAmount - feeAmount;

        super._transfer(sender, recipient, netAmount);
        super._transfer(sender, address(0), burnAmount); // Burn tokens
        super._transfer(sender, _msgSender(), feeAmount); // Transfer fee to admin or a dedicated address
    }

    function _mint(address account, uint256 amount) internal virtual override onlyRole(MINTER_ROLE) {
        super._mint(account, amount);
    }
}
