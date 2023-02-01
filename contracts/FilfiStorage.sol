// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract FilfiStorage {

    address public governor;
    address public pauseGuardian;

    // The address of the FIL token
    address public baseToken;

    // system total supply、total borrow、total pledge
    // struct TotalsStatistics {
    //     uint128 totalSupply;
    //     uint128 totalBorrow;
    //     uint128 totalPledged;
    //     uint40 lastAccrualTime;
    // }

    // node asset information
    struct NodeAsset {
        // 3 slot

        // miner address 
        address  miner;
        // pledge scale
        uint32 pledgeScale;
        // total pledge amount of assets
        uint128  pledgedAmt;
        // miner balance·
        uint128  balance;
        // Valuation of pledged miner nodes that can be borrowed
        uint128  canBorrowedBalance;
        // The beneficiary has withdrawn the amount
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
        
    }


    uint64 internal baseBorrowInterestRate;
    uint64 internal baseSupplyInterestRate;
    

    uint128 internal totalSupply;
    uint128 internal totalBorrow;
    uint128 internal totalPledged;

    uint64 internal liquidateCollateralFactor;
    uint40 internal lastAccrualTime;

    // TotalsStatistics internal totalsStatistics;

    mapping(address => mapping(address => bool)) public isAllowed;

    mapping(address => UserAccount) public userAccounts;

    // pledge miner node  information : owner => miner => NodeAsset
    mapping(address => mapping(address => NodeAsset) ) public nodeAssets;


    
}