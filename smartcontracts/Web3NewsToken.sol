// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Web3NewsTokenBase.sol";
import "./TokenVesting.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.3.3/contracts/access/AccessControl.sol";

contract Web3NewsToken is Web3NewsTokenBase, AccessControl {
    // Define roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant WRITER_ROLE = keccak256("WRITER_ROLE");
    bytes32 public constant READER_ROLE = keccak256("READER_ROLE");

    constructor(address reserveAddress) Web3NewsTokenBase(reserveAddress, "Web3NewsToken", "W3NT") {
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    function createVesting(
        address beneficiary,
        uint256 vestingStartTime,
        uint256 vestingDuration,
        uint256 vestingCliffDuration
    ) public onlyRole(ADMIN_ROLE) returns (address) {
        TokenVesting tokenVesting = new TokenVesting(
            IERC20(address(this)),
            beneficiary,
            vestingStartTime,
            vestingDuration,
            vestingCliffDuration
        );
        grantRole(ADMIN_ROLE, address(tokenVesting));
        return address(tokenVesting);
    }

    // Grant writer role to an address
    function grantWriterRole(address writer) public onlyRole(ADMIN_ROLE) {
        grantRole(WRITER_ROLE, writer);
    }

    // Revoke writer role from an address
    function revokeWriterRole(address writer) public onlyRole(ADMIN_ROLE) {
        revokeRole(WRITER_ROLE, writer);
    }

    // Grant reader role to an address
    function grantReaderRole(address reader) public onlyRole(ADMIN_ROLE) {
        grantRole(READER_ROLE, reader);
    }

    // Revoke reader role from an address
    function revokeReaderRole(address reader) public onlyRole(ADMIN_ROLE) {
        revokeRole(READER_ROLE, reader);
    }

    function contribute(string memory article) public onlyRole(WRITER_ROLE) {
        _contribute(msg.sender, article);
    }

    function readArticle() public onlyRole(READER_ROLE) {
        _readArticle(msg.sender);
    }

    function shareOnSocialMedia() public onlyRole(READER_ROLE) {
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

    function tip(address recipient, uint256 amount) public {
        require(hasRole(WRITER_ROLE, recipient), "Recipient must have the writer role");
        _transfer(msg.sender, recipient, amount);
        emit Tip(msg.sender, recipient, amount);
    }

    function distributeToProject(address projectAddress, uint256 amount) public onlyRole(ADMIN_ROLE) {
        _transfer(msg.sender, projectAddress, amount);
        emit ProjectDistribution(msg.sender, projectAddress, amount);
    }
}
