// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract FilfiStorage {

    uint40 internal lastAccrualTime;
    uint8 internal pauseFlags;

    mapping(address => TotalsCollateral) public totalsCollateral;

    struct TotalsCollateral {
        uint128 totalSupplyAsset;
        uint128 _reserved;
    }

    mapping(address => mapping(address => bool)) public isAllowed;

    mapping(address => UserBasic) public userBasic;

    struct UserBasic {
        uint128 pricipal;
        uint64 baseTrackingIndex;
        uint64 baseTrackingAccrued;
    }
    
}