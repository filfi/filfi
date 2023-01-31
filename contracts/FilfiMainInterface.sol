// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./FilfiConfiguration.sol";
import "./FilfiStorage.sol";
import "./FilfiMath.sol";

abstract contract FilfiMainInterface is FilfiConfiguration, FilfiStorage, FilfiMath {

    error AlreadyInitialized();
    error TimestampTooLarge();
    error TransferInFailed();
    error TransferOutFailed();
    error Unauthorized();
    error ChangeBeneficiaryFailed();

    uint64 internal constant FACTOR_SCALE = 1e16;


    uint64 internal constant SECONDS_PER_YEAR = 31_536_000;

    uint64 internal constant PRECISION_SCALE = 1e18;

    uint64 internal constant BASE_SUPPLY_INTEREST_RATE = uint64(3*FACTOR_SCALE/SECONDS_PER_YEAR);
    uint64 internal constant BASE_BORROW_INTEREST_RATE = uint64(7*FACTOR_SCALE/SECONDS_PER_YEAR);    

    uint64 internal constant LIQUIDATE_COLLATERAL_FACTOR = 80*FACTOR_SCALE;


    // Fund deposit and withdraw events
    event Supply(address indexed from, address indexed dst, uint amount);
    event InterestWithdraw(address indexed to, uint amount);
    event Withdraw(address indexed src, address indexed to, uint amount);

    // Borrow and repay events
    event Borrow(address indexed dst, uint amount);
    event Repay(address indexed src,  uint amount);

    // Pledge event
    event Pledge(address indexed src, address indexed dst, address indexed miner);
    event Unpledge(address indexed src, address indexed dst, address indexed miner);




    function hasPermission(address owner, address manager) public view returns (bool) {
        return owner == manager || isAllowed[owner][manager];
    }

    function initializeStorage() virtual external;
    function getNowInternal() virtual internal view returns (uint40);

    // Fund deposit and withdraw functions
    function supply( uint amount) virtual external;
    function interestWithdraw(uint amount) virtual external;
    function withdraw(uint amount) virtual external;

    // Borrow and repay functions
    function borrow(uint amount) virtual external;
    function repay(uint amount) virtual external;


    // Pledge function
    function pledge(address miner, uint amount) virtual external;
    function unpledge(address miner) virtual external;

    // Liquidation function
    
    function supplyBalanceOf(address owner) virtual external view returns (uint256);
    function borrowBalanceOf(address owner) virtual external view returns (uint256);
    function pledgeBalanceOf(address owner) virtual external view returns (uint256);


    // set interest rate function
    function setBaseSupplyInterestRate(uint baseSupplyInterestRate) virtual external;
    function setBaseBorrowInterestRate(uint baseBorrowInterestRate) virtual external;
    function setLiquidateCollateralFactor(uint liquidateCollateralFactor) virtual external;

    function totalSupplyInterestOf(address owner) virtual external view returns (uint256);
    function totalBorrowInterestOf(address owner) virtual external view returns (uint256);
    function unClaimSupplyInterestOf(address owner) virtual external view returns (uint256);
    function unClaimBorrowInterestOf(address owner) virtual external view returns (uint256);


}