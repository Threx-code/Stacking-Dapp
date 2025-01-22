// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.29;


import {Address} from "./Address.sol";
import {Context} from "./Context.sol";
import {IERC20} from "./IERC20.sol";
import {Initializable} from "./Initializable.sol";
import {Ownable} from "./Ownable.sol";
import {ReentrancyGuard} from "./ReentrancyGuard.sol";


contract TokenStaking is Ownable, ReentrancyGuard, Initializable {

    // struct to store the user details
    struct User {
       uint256 stakedAmount;
       uint256 rewardAmount;
       uint256 lastStakedTime;
       uint256 lastRewardCalculationTime;
       uint256 rewardsClaimedSoFar; 
    }


    uint256 _minimumStakingAmount; // minimum staking amount for pgram
    uint256 _maxStakeTokenLimit; // maximum staking token limit for program

    uint256 _stakeStartDate;
    uint256 _stakeEndDate;

    uint256 _totalStakedTokens;

    uint256 _totalUsers;

    uint256 _stakeDays;

    uint256 _earlyUnstakeFeePercentage;


    bool _isStakingPaused;


    address private __tokenAddress;


    uint256 _apyRate;

    uint256 public constant PERCENTAGE_DENOMINATOR = 10000;
    uint256 public constant APY_RATE_CHANGE_THRESHOLD = 10;


    mapping(address => User) private _users;


    event Stake(address indexed user, uint256 amount);
    event UnStake(address indexed user, uint256 amount);
    event EarlyUnstakeFee(address indexed user, uint256 amount);
    event ClaimedReward(address indexed user, uint256 amount);


    modifier whenTreasuryHasBalance(uint256 amount) {
        require(
            IERC20(_tokenAddress).balanceOf(address(this)) >= amount, 
            "TokenStaking: Insufficient funds in treasury"
        );

        _;
    }


    function initialize(
        address owner_,
        address tokenAddress_,
        uint256 apyRate_,
        uint256 minimumStakeingAmount_,
        uint256 maxStakeTokenLimit_,
        uint256 stakeStartDate_,
        uint256 stakeEndDate_,
        uint256 stakeDays_,
        uint256 earlyUnstakeFeePercentage_
    ) public virtual initializer {
        __TokenStaking_init_unchained(
            owner_,
            tokenAddress_,
            apyRate_,
            minimumStakeingAmount_,
            maxStakeTokenLimit_,
            stakeStartDate_,
            stakeEndDate_,
            stakeDays_,
            earlyUnstakeFeePercentage_
        )
    }


    function __TokenStaking_init_unchained(
        address owner_,
        address tokenAddress_,
        uint256 apyRate_,
        uint256 minimumStakeingAmount_,
        uint256 maxStakeTokenLimit_,
        uint256 stakeStartDate_,
        uint256 stakeEndDate_,
        uint256 stakeDays_,
        uint256 earlyUnstakeFeePercentage_
    ) internal onlyInitializing {
        require(_apyRate <= 10000, "TokenStaking: apy rate should be less than or equal to 10000");
        require(stakeDays_ > 0, "TokenStaking: stake days should be greater than 0");
        require(tokenAddress_ != address(0), "TokenStaking: token address is zero");
        require(stakeStartDate_ < stakeEndDate_, "TokenStaking: stake start date should be less than stake end date");

        _transferOwnership(owner_);
        _tokenAddress = tokenAddress_;
        _apyRate = apyRate_;
        _minimumStakingAmount = minimumStakeingAmount_;
        _maxStakeTokenLimit = maxStakeTokenLimit_;
        _stakeStartDate = stakeStartDate_;
        _stakeEndDate = stakeEndDate_;
        _stakeDays = stakeDays_;
        _earlyUnstakeFeePercentage = earlyUnstakeFeePercentage_;
    }


    /*View Method Statrt */


    /** 
     * @notice this function is used to get the minimum staking amount
     * @return minimum staking amount
     */
   function getMinimumStakingAmount() external view returns(uint256){
       return _minimumStakingAmount;
   }

    /** 
     * @notice this function is used to get the maximum staking token limit
     * @return maximum staking token limit
     */
   function getMaximumStakingTokenLimit() external view returns(uint256){
       return _maxStakeTokenLimit;
   }

    /** 
     * @notice this function is used to get the staking start date
     * @return staking start date
     */
    function getStakeStartDate() external view returns(uint256){
        return _stakeStartDate;
    }


    /** 
     * @notice this function is used to get the staking end date
     * @return staking end date
     */
    function getStakeEndDate() external view returns(uint256){
        return _stakeEndDate;
    }


    /** 
     * @notice this function is used to get the total staked tokens
     * @return total staked tokens
     */
    function getTotalStakedTokens() external view returns(uint256){
        return _totalStakedTokens;
    }


    /** 
     * @notice this function is used to get the total users
     * @return total users
     */
    function getTotalUsers() external view returns(uint256){
        return _totalUsers;
    }


    /** 
     * @notice this function is used to get the stake days
     * @return stake days
     */
    function getStakeDays() external view returns(uint256){
        return _stakeDays;
    }


    /** 
     * @notice this function is used to get the early unstake fee percentage
     * @return early unstake fee percentage
     */
    function getEarlyUnstakeFeePercentage() external view returns(uint256){
        return _earlyUnstakeFeePercentage;
    }


    /** 
     * @notice this function is used to get the staking status
     * @return staking status
     */
    function getStakingStatus() external view returns(bool){
        return _isStakingPaused;
    }


    /** 
     * @notice this function is used to get the apy rate
     * @return apy rate
     */

    function getApyRate() external view returns(uint256){
        return _apyRate;
    }


    /**
     * @notice this function is used to get the user estimated reward amount
     * @return user estimated reward amount
     */
    function getUserEstimatedRewards() external view returns (uint256){
        (uint256 amount,) = _getUserEstimatedRewards(msg.sender);

        return _users[msg.sender].rewardAmount + amount;
    }


    /**
     * @notice this function is used to get the user staked amount
     * @return user staked amount
     */
    function getWithdrawalAmount() external view returns(uint256){
        return IERC20(_tokenAddress).balanceOf(address(this)) - _totalStakedTokens;
    }

    /**
     * @notice this function is used to get the user staked amount
     * @param userAddress address of the user
     * @return user staked amount
     */
    function getUser(address userAddress) external view returns(User memory){
        return _users[userAddress];
    }


    /**
     * @notice this function is used to get the user staked amount
     * @param _user address of the user
     * @return user staked amount
     */
    function isStakeHolder(address _user) external view returns(bool){
        return _users[_user].stakedAmount > 0;
    }

    /*View Method End */


    /* Owner Method Start */

    /**
     * @notice this function is used to update the minimum staking amount
     * @param amount minimum staking amount
     */
    function updateMinimumStakingAmount(uint256 amount) external onlyOwner {
        _minimumStakingAmount = amount;
    }


    /**
     * @notice this function is used to update the maximum staking token limit
     * @param amount maximum staking token limit
     */
    function updateMaximumStakingTokenLimit(uint256 amount) external onlyOwner {
        _maxStakeTokenLimit = amount;
    }


    /**
     * @notice this function is used to update the staking start date
     * @param date staking start date
     */
    function updateStakingEndDate(uint256 date) external onlyOwner {
        _stakeEndDate = date;
    }


    /**
     * @notice this function is used to update the staking start date
     * @param date staking start date
     */
    function updateEarlyUnstakeFeePercentage(uint256 percentage) external onlyOwner {
        _earlyUnstakeFeePercentage = percentage;
    }


    /**
     * @notice this function is used to stake tokens for a specific user
     * @dev this function can only be used to stake tokens for specific user
     * 
     * @param user address of the user
     * @param amount staking amount
     */

    function stakeForUser(address user, uint256 amount) external onlyOwner nonReentrant {
        _stakeTokens(user, amount);
    }


    /**
     * @notice enable/disable staking
     * @dev this function is used to enable/disable staking
     */
    function toggleStakingStatus() external onlyOwner {
        _isStakingPaused = !_isStakingPaused;
    }


    /**
     * @notice Withdraw the specific amount if possible
     * 
     * @dev this function is used to withdraw the specific amount if possible
     * 
     * @param amount amount to withdraw
     */
    function withdraw(uint256 amount) external onlyOwner nonReentrant {
        require(this.getWithdrawalAmount() >= amount, "TokenStaking: not enough balance to withdraw");
        IERC20(_tokenAddress).transfer(msg.sender, amount);
    }

    /* Owner Method End */


    /*User Method Start */

    /**
     * @notice this function is used to stake tokens
     * @param amount staking amount
     */
    function stake(uint256 amount) external nonReentrant {
        _stakeTokens(msg.sender, amount);
    }

    
    function _stakenTokens(address user_, uint256 amount_) private {
        require(!_isStakingPaused, "TokenStaking: staking is paused");
        require(amount_ > 0, "TokenStaking: amount should be greater than 0");

        uint256 currentTime = getCurrentTime();
        require(currentTime > _stakeStartDate, "TokenStaking: staking is not started yet");
        require(currentTime < _stakeEndDate, "TokenStaking: staking is ended");
        require(_totalStakedTokens + amount_ <= _maxStakeTokenLimit, "TokenStaking: amount is greater than maximum staking limit");
        require(amount_ >= _minimumStakingAmount, "TokenStaking: amount is less than minimum staking amount");
        

        if(_users[user_].stakedAmount != 0){
            _calculateRewards(user_);
        }else{
            _users[user_].lastRewardCalculationTime = currentTime;
            _totalUsers++;
        }

        _users[user_].stakedAmount += amount_;
        _users[user_].lastStakedTime = currentTime;
        _totalStakedTokens += amount_;


        require(IERC20(_tokenAddress).transferFrom(user_, address(this), amount_), "TokenStaking: failed to transfer tokens");

        emit Stake(user_, amount_);
    }


    /**
     * @notice this function is used to unstake tokens
     * @param _amount unstaking amount
     */
    function unstake(uint256 _amount) external nonReetrant whenTreasuryHasBalance(_amount){
        address user = msg.sender;

        require(_amount > 0, "TokenStaking: amount should be greater than 0");
        require(this.isStakeHolder(user), "TokenStaking: user is not a stakeholder");
        require(_users[user].stakedAmount >= _amount, "TokenStaking: amount is greater than staked amount");


        //calculate user reward
        _calculateRewards(user);

        uint256 feeEarlyUnstake = 0;

        if(getCurrentTime() <= _users[user].lastStakedTime + _stakeDays){
            feeEarlyUnstake = ((_amount * _earlyUnstakeFeePercentage) / PERCENTAGE_DENOMINATOR);
            emit EarlyUnstakeFee(user, feeEarlyUnstake);
        }

        uint256 amountToUnstake = _amount - feeEarlyUnstake;

        _users[user].stakedAmount -= _amount;
        _totalStakedTokens -= _amount;

        if(_users[user].stakeAmount == 0){
            // delete the user _users[user]
            _totalUsers--;
        }

        require(IERC20(_tokenAddress).transfer(user, amountToUnstake), "TokenStaking: failed to transfer tokens");

        emit UnStake(user, amountToUnstake);
    }


    /**
     * @notice this function is used to claim reward
     */
    function claimReward() external nonReentrant whenTreasuryHasBalance(_users[msg.sender].rewardAmount){
        _calculateRewards(msg.sender);

        uint256 rewardAmount = users[msg.sender].rewardAmount;

        require(rewardAmount > 0, "TokenStaking: no reward to claim");
        require(IERC20(_tokenAddress).transfer(msg.sender, rewardAmount), "TokenStaking: failed to transfer tokens");


        _users[msg.sender].rewardAmount = 0;
        _users[msg.sender].rewardsClaimedSoFar += rewardAmount;

        emit ClaimedReward(msg.sender, rewardAmount);
    }

    /*User Method End */


    /*Internal Method Start  Helper functions */


    /**
     * @notice this function is used to calculate rewards for a user
     * @param _user address of the user
     */
    function _calculateRewards(address _user) private {
        (uint256 userReward, uint256 currentTime) = _getUserEstimatedRewards(_user);

        _users[_user].rewardAmount += userReward;
        _users[_user].lastRewardCalculationTime = currentTime;
    }


    /**
     * @notice this function is used to get the estimated rewards for a user
     * @param _user address of the user
     * @return user reward and current time
     */
    function _getUserEstimatedRewards(address _user) private view returns(uint256, uint256){
        uint256 userReward = 0;
        uint256 userTimestamp = _users[_user].lastRewardCalculationTime;

        uint256 currentTime = getCurrentTime();

        if(currentTime > _users[_user].lastStakedTime + _stakeDays){
            currentTime = _users[_user].lastStakedTime + _stakeDays;
        }


        uint256 totalStakedTime = currentTime - userTimestamp;

        userReward += ((totalStaked * _users[_user].stakeAmount * _apyRate) / 365 days) / PERCENTAGE_DENOMINATOR;

        return (userReward, currentTime);
    }


    function getCurrentTime() internal view virtual returns (uint256){
        return block.timestamp;
    }



}