// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;


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


    bool _is_stakingPaused;


}