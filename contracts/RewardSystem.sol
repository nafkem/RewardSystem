// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract RewardSystem is ReentrancyGuard {

    IERC20 public token;
    mapping(address => uint256) public balances;
    uint256 public totalRewardsDistributed;
    address public owner;

    event Rewarded(address indexed user, uint256 amount);
    event Redeemed(address indexed user, uint256 amount);
    event BalanceChecked(address indexed user, uint256 balance);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    
    constructor(address tokenAddress) {token = IERC20(tokenAddress);
    }

    function redeemPoints(uint256 amount, uint256 tokenPrice) 
    external nonReentrant  {
    require(balances[msg.sender] >= amount, "Insufficient points balance");
    uint256 tokensToTransfer = amount * tokenPrice;
    require(token.balanceOf(address(this)) >= tokensToTransfer, "Not enough tokens in contract");

    balances[msg.sender] -= amount;
    token.transfer(msg.sender, tokensToTransfer);
    emit Redeemed(msg.sender, tokensToTransfer);
}

    // Reward points to a user
        function rewardUser(address user, uint256 amount) external nonReentrant  onlyOwner {
        balances[user] += amount;
        totalRewardsDistributed += amount;
        emit Rewarded(user, amount);
    }

    // Redeem points for tokens
        function redeemPoints(uint256 amount, uint256 tokenPrice) external nonReentrant  {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        uint256 tokensToReceive = amount * tokenPrice;
        balances[msg.sender] -= amount;
        emit Redeemed(msg.sender, tokensToReceive);
    }

    // Check user's reward balance
        function checkBalance() public {
        uint256 userBalance = balances[msg.sender];
        emit BalanceChecked(msg.sender, userBalance);
    }
}
