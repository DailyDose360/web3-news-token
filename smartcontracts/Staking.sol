// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Web3NewsToken.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract Staking {
    using SafeERC20 for IERC20;

    Web3NewsToken public token;
    uint256 public constant rewardRate = 10; // 1% reward rate per epoch
    uint256 public constant epochDuration = 7 days; // One epoch lasts for 7 days

    mapping(address => uint256) public stakingBalances;
    mapping(address => uint256) public rewardBalances;
    mapping(address => uint256) public lastClaimedEpoch;

    uint256 public currentEpoch = 1;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);

    constructor(address _token) {
        token = Web3NewsToken(_token);
    }

    function stake(uint256 amount) external {
        token.safeTransferFrom(msg.sender, address(this), amount);
        stakingBalances[msg.sender] += amount;
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external {
        require(stakingBalances[msg.sender] >= amount, "Insufficient staking balance");
        token.safeTransfer(msg.sender, amount);
        stakingBalances[msg.sender] -= amount;
        emit Unstaked(msg.sender, amount);
    }

    function claimReward() external {
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No reward available");
        token.mint(msg.sender, reward);
        rewardBalances[msg.sender] += reward;
        lastClaimedEpoch[msg.sender] = currentEpoch;
        emit RewardClaimed(msg.sender, reward);
    }

    function calculateReward(address user) public view returns (uint256) {
        if (lastClaimedEpoch[user] == currentEpoch) {
            return 0;
        }
        return (stakingBalances[user] * rewardRate) / 1000;
    }

    function nextEpoch() external {
        require(block.timestamp >= currentEpoch * epochDuration, "Epoch not finished");
        currentEpoch++;
    }
}
