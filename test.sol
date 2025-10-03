pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract YieldVault {
    IERC20 public depositToken;
    mapping(address => uint256) public userShares;
    uint256 public totalShares;
    uint256 public lastRewardTime;
    uint256 public rewardRate = 5; // 5% annual yield

    constructor(address _token) {
        depositToken = IERC20(_token);
        lastRewardTime = block.timestamp;
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be positive");

        uint256 shares = amount;
        if (totalShares > 0) {
            uint256 vaultBalance = depositToken.balanceOf(address(this));
            shares = (amount * totalShares) / vaultBalance;
        }

        userShares[msg.sender] += shares;
        totalShares += shares;

        depositToken.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 shares) external {
        require(userShares[msg.sender] >= shares, "Insufficient shares");

        compoundRewards();

        uint256 vaultBalance = depositToken.balanceOf(address(this));
        uint256 withdrawAmount = (shares * vaultBalance) / totalShares;

        userShares[msg.sender] -= shares;
        totalShares -= shares;

        depositToken.transfer(msg.sender, withdrawAmount);
    }

    function compoundRewards() public {
        uint256 timeElapsed = block.timestamp - lastRewardTime;
        uint256 vaultBalance = depositToken.balanceOf(address(this));

        uint256 rewards = vaultBalance * rewardRate * timeElapsed / 365 days / 100;

        // Simulate rewards being added
        lastRewardTime = block.timestamp;
    }

    function emergencyWithdraw() external {
        uint256 userBalance = userShares[msg.sender];
        require(userBalance > 0, "No balance");

        uint256 vaultBalance = depositToken.balanceOf(address(this));
        uint256 withdrawAmount = (userBalance * vaultBalance) / totalShares;

        totalShares -= userBalance;
        userShares[msg.sender] = 0;

        depositToken.transfer(msg.sender, withdrawAmount);
    }
}
