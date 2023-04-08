// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol";

contract TokenVesting is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    IERC20 public token;
    uint256 public totalVestingAmount;
    uint256 public vestingStartTime;
    uint256 public vestingDuration;
    uint256 public vestingCliffDuration;
    address public beneficiary;

    bool public tokensClaimed;

    event TokensReleased(address beneficiary, uint256 amount);

    constructor(
        IERC20 _token,
        address _beneficiary,
        uint256 _vestingStartTime,
        uint256 _vestingDuration,
        uint256 _vestingCliffDuration
    ) {
        require(_beneficiary != address(0), "Invalid beneficiary address");
        require(_vestingStartTime > block.timestamp, "Vesting start time should be in the future");
        require(_vestingDuration > 0, "Vesting duration should be greater than 0");
        require(_vestingCliffDuration < _vestingDuration, "Vesting cliff duration should be less than vesting duration");

        token = _token;
        beneficiary = _beneficiary;
        vestingStartTime = _vestingStartTime;
        vestingDuration = _vestingDuration;
        vestingCliffDuration = _vestingCliffDuration;

        _setupRole(ADMIN_ROLE, msg.sender);
    }

    function setTotalVestingAmount(uint256 _totalVestingAmount) external onlyRole(ADMIN_ROLE) {
        require(totalVestingAmount == 0, "Total vesting amount is already set");
        require(token.balanceOf(address(this)) >= _totalVestingAmount, "Not enough tokens for vesting");
        totalVestingAmount = _totalVestingAmount;
    }

    function claimTokens() external {
        require(msg.sender == beneficiary, "Only the beneficiary can claim tokens");
        require(!tokensClaimed, "Tokens have already been claimed");
        require(block.timestamp >= vestingStartTime + vestingCliffDuration, "Cliff duration not reached");

        uint256 elapsedTime = block.timestamp - vestingStartTime;
        uint256 vestedAmount;

        if (elapsedTime >= vestingDuration) {
            vestedAmount = totalVestingAmount;
            tokensClaimed = true;
        } else {
            vestedAmount = (totalVestingAmount * elapsedTime) / vestingDuration;
        }

        uint256 claimableAmount = vestedAmount - token.balanceOf(beneficiary);
        require(claimableAmount > 0, "No tokens available to claim");

        token.transfer(beneficiary, claimableAmount);
        emit TokensReleased(beneficiary, claimableAmount);
    }
}

