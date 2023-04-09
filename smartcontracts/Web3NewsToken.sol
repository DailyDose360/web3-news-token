// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Web3NewsTokenBase.sol";
import "./TokenVesting.sol";

contract Web3NewsToken is Web3NewsTokenBase {
    // Minimum time intervals in seconds between function calls
    uint256 public constant contributeInterval = 86400; // 24 hours
    uint256 public constant readArticleInterval = 3600; // 1 hour
    uint256 public constant shareOnSocialMediaInterval = 7200; // 2 hours

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant WRITER_ROLE = keccak256("WRITER_ROLE");
    bytes32 public constant READER_ROLE = keccak256("READER_ROLE");
    bytes32 public constant SHARER_ROLE = keccak256("SHARER_ROLE");

    mapping(address => uint256) private lastContribution;
    mapping(address => uint256) private lastArticleRead;
    mapping(address => uint256) private lastSocialMediaShare;

    // Deflationary Mechanisms
    uint256 public burnRate = 100; // 1% of the transaction amount will be burnt
    uint256 public feeRate = 50; // 0.5% of the transaction amount will be charged as a fee

    constructor(address reserveAddress) Web3NewsTokenBase(reserveAddress, "Web3NewsToken", "W3NT") {
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, address(this)); // Set up the Minter role for the contract itself
        _setRoleAdmin(WRITER_ROLE, MINTER_ROLE);
        _setRoleAdmin(READER_ROLE, MINTER_ROLE);
        _setRoleAdmin(SHARER_ROLE, MINTER_ROLE);

        emit RoleAssigned(ADMIN_ROLE, msg.sender);
        emit RoleAssigned(MINTER_ROLE, address(this));

        uint256 deployerTokens = maxTokens - reservedTokens;
        _initialMint(msg.sender, deployerTokens);

        uint256 reserveTokensAmount = reservedTokens;
        _initialMint(reserveAddress, reserveTokensAmount);
    }

    function _initialMint(address to, uint256 amount) internal {
        _mint(to, amount);
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
        require(hasRole(WRITER_ROLE, msg.sender), "Caller is not a writer");
        require(block.timestamp - lastContribution[msg.sender] >= contributeInterval, "Minimum time interval not met for contribute");
        lastContribution[msg.sender] = block.timestamp;
        _contribute(msg.sender, article);
    }

    function readArticle() public {
        require(hasRole(READER_ROLE, msg.sender), "Caller is not a reader");
        require(block.timestamp - lastArticleRead[msg.sender] >= readArticleInterval, "Minimum time interval not met for readArticle");
        lastArticleRead[msg.sender] = block.timestamp;
        _readArticle(msg.sender);
    }

    function shareOnSocialMedia() public {
        require(hasRole(SHARER_ROLE, msg.sender), "Caller is not a sharer");
        require(block.timestamp - lastSocialMediaShare[msg.sender] >= shareOnSocialMediaInterval, "Minimum time interval not met for shareOnSocialMedia");
        lastSocialMediaShare[msg.sender] = block.timestamp;
        _shareOnSocialMedia(msg.sender);
    }

    function _contribute(address writer, string memory article) internal {
        _mint(writer, 200 * (10 ** decimals()));
        // Additional logic for saving the contributed article
    }

    function _readArticle(address reader) internal {
        _mint(reader, 10 * (10 ** decimals()));
        // Additional logic for marking the article as read
    }

    function _shareOnSocialMedia(address sharer) internal {
        _mint(sharer, 20 * (10 ** decimals()));
        // Additional logic for tracking the social media share
    }

    function assignRole(bytes32 role, address account) external onlyRole(MINTER_ROLE) {
        grantRole(role, account);
        emit RoleAssigned(role, account);
    }
}
