/// SPDX-Liscence-Identifier: MIT
import "https://github.com/Synthetixio/synthetix/blob/develop/contracts/StakingRewards.sol";

contract AttentionToken is StakingRewards {

    IERC20 public rewardsToken;
    IERC20 public stakingToken;

    address public owner;

    //Duration of rewards to be paid out in seconds
    uint public rewardsDuration = 7 days;

    //Timestamp of when rewards are paid out
    uint public periodFinish = 0;

    //Minimum of last updated time and reward duration
    uint public lastUpdateTime;
    //Reward per token stored
    uint public rewardPerTokenStored;
    //Sum of rewards(rewardRate * rewardsDuration * 1e18)/ totalSupply
    uint public rewardPerToken;
    //Reward to be paid out per second
    uint public rewardRate;
    //User address => rewards to be claimed
    mapping(address => uint) public userRewardPerTokenPaid;
    //User address => rewards claimed
    mapping(address => uint) public rewards;

    //Total staked
    uint public totalStaked;//totalSupply
    //User address => amount staked
    mapping(address => uint) public stakedBalances;//balanceOf

    constructor(
        address _rewardsDistribution,
        address _rewardsToken,
        address _stakingToken
    ) StakingRewards(_rewardsDistribution, _rewardsToken, _stakingToken) {
        rewardsToken = IERC20(_rewardsToken);
        stakingToken = IERC20(_stakingToken);
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
    modifieer updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint) {
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }
    function rewardPerToken() public view returns (uint) {
        if (totalStaked == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored +
            ((lastTimeRewardApplicable() - lastUpdateTime) * rewardRate * 1e18) /
            totalStaked;
    }
    function stake(uint amount) public updateReward(msg.sender) checkhalve checkStart {
        require(amount > 0, "Cannot stake 0");
        totalStaked = totalStaked + amount;
        stakedBalances[msg.sender] = stakedBalances[msg.sender] + amount;
        stakingToken.transferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }
    function withdraw(uint amount) public updateReward(msg.sender) checkhalve checkStart {
        require(amount > 0, "Cannot withdraw 0");
        totalStaked = totalStaked - amount;
        stakedBalances[msg.sender] = stakedBalances[msg.sender] - amount;
        stakingToken.transfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }
    function earned(address account) public view returns (uint) {
        return
            (stakedBalances[account] *
                (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18 +
            rewards[account];
    }
    function getReward() public updateReward(msg.sender) checkhalve checkStart {
        uint reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }
    function setRewardsDuration(uint _rewardsDuration) external onlyOwner {
        require(
            block.timestamp > periodFinish,
            "Previous rewards period must be complete before changing the duration for the new period"
        );
        rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(rewardsDuration);
    }
    function notifyRewardAmount(uint reward)
        external
        onlyOwner
        updateReward(address(0))
    {
        if (block.timestamp >= periodFinish) {
            rewardRate = reward / rewardsDuration;
        } else {
            uint remaining = periodFinish - block.timestamp;
            uint leftover = remaining * rewardRate;
            rewardRate = (reward + leftover) / rewardsDuration;
        }
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + rewardsDuration;
        emit RewardAdded(reward);
    }
    function _min(uint a, uint b) internal pure returns (uint) {
        return a < b ? a : b;
    }

}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
