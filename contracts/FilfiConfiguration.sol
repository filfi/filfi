// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract FilfiConfiguration {

    struct Configuration {
        // Contract Governance Committee
        address governor;

        // base deposit rate of return per second
        uint64 BaseSupplyInterestRate;
        // base borrow rate of return per second
        uint64 BaseBorrowInterestRate;

        // collateral liquidation line
        uint64 liquidateCollateralFactor;

    }


    // User asset information

}