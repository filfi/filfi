// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract FilfiStorage {
    address public governor;
    address public pauseGuardian;

    // The address of the FIL token
    address public baseToken;

    // node asset information
    struct NodeAsset {
        // 3 slot
        string  minerId;
        uint32 pledgeScale;
        uint128  pledgedAmt;
        uint128  balance;
        uint128  canBorrowedBalance;
        uint128 beneficiaryWithdrawnAmt;
    }

    // user account information
    struct UserAccount {
        // 3 slot
        uint104 supplyBalance;
        uint104 borrowBalance;
        uint40 lastAccrualTime;
        
        uint64 supplyTotalInterest;
        uint64 unClaimSupplyInterest;
        uint64 borrowTotalInterest;
        uint64 unClaimBorrowInterest;

        uint128  canBorrowedBalance;
        bool isUsed;
        
    }


    uint64 internal baseBorrowInterestRate;
    uint64 internal baseSupplyInterestRate;
    uint128 internal totalSupply;
    uint128 internal totalBorrow;
    uint128 internal totalPledged;
    uint64 internal liquidateCollateralFactor;
    uint40 internal lastAccrualTime;
    mapping(address => mapping(address => bool)) public isAllowed;
    mapping(address => UserAccount) public userAccounts;
    // pledge miner node  information : owner => miner => NodeAsset
    mapping(address => mapping(string => NodeAsset) ) public nodeAssets;   
}