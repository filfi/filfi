// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract FilfiStorage {

    struct TotalsStatistics {
        uint104 totalSupply;
        uint104 totalBorrow;
        uint48 lastAccrualTime;
    }

    struct NodeAsset {
        // 3 slot

        // miner address 
        address  miner;
        // total pledge amount of assets
        uint128  pledgedAmt;
        // miner balance·
        uint128  balance;
        // Valuation of pledged miner nodes that can be borrowed
        uint128  valuation;
        // The beneficiary has withdrawn the amount
        uint128 beneficiaryWithdrawnAmt;
    }


    struct UserAccount {
        int104 principal;
        uint56 totalAccrued;
        uint56 accrued;
        uint40 lastAccrualTime;
    }



    uint40 internal lastAccrualTime;


    mapping(address => mapping(address => bool)) public isAllowed;

    mapping(address => UserAccount) public userAccounts;

    mapping(address => NodeAsset) public nodeAssets;


    
}