// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RewardSystem is ReentrancyGuard {
    IERC20 public immutable token;
    mapping(address => uint256) public balances;
    uint256 public totalRewardsDistributed;
    address public immutable owner;

    event Rewarded(address indexed user, uint256 amount);
    event Redeemed(address indexed user, uint256 amount);
    event BalanceChecked(address indexed user, uint256 balance);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    constructor(address tokenAddress) {
        require(tokenAddress != address(0), "Token address cannot be zero");
        token = IERC20(tokenAddress);
        owner = msg.sender;
    }

    /**
     * @notice Reward points to a user.
     * @param user The address of the user to reward.
     * @param amount The number of reward points to add.
     */
    function rewardUser(address user, uint256 amount) external nonReentrant onlyOwner {
        require(user != address(0), "Cannot reward the zero address");
        require(amount > 0, "Reward amount must be greater than zero");

        balances[user] += amount;
        totalRewardsDistributed += amount;

        emit Rewarded(user, amount);
    }

    /**
     * @notice Redeem points for tokens.
     * @param amount The number of reward points to redeem.
     * @param tokenPrice The price of one reward point in tokens.
     */
    function redeemPoints(uint256 amount, uint256 tokenPrice) external nonReentrant {
        require(amount > 0, "Amount must be greater than zero");
        require(balances[msg.sender] >= amount, "Insufficient points balance");
        require(tokenPrice > 0, "Token price must be greater than zero");

        uint256 tokensToTransfer = amount * tokenPrice;
        require(token.balanceOf(address(this)) >= tokensToTransfer, "Not enough tokens in contract");

        balances[msg.sender] -= amount;
        token.transfer(msg.sender, tokensToTransfer);

        emit Redeemed(msg.sender, tokensToTransfer);
    }

    /**
     * @notice Check the reward balance of the caller.
     * @return The current reward points balance of the caller.
     */
    function checkBalance() external view returns (uint256) {
        uint256 userBalance = balances[msg.sender];
        emit BalanceChecked(msg.sender, userBalance);
        return userBalance;
    }

    /**
     * @notice Withdraw tokens from the contract (owner only).
     * @param amount The amount of tokens to withdraw.
     */
    function withdrawTokens(uint256 amount) external onlyOwner nonReentrant {
        require(amount > 0, "Amount must be greater than zero");
        require(token.balanceOf(address(this)) >= amount, "Not enough tokens in contract");

        token.transfer(owner, amount);
    }
}
