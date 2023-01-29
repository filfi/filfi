// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./FilfiMainInterface.sol";

contract Filfi is FilfiMainInterface {

    address public override immutable governor;

    address public override immutable pauseGuardian;

    constructor() {

        unchecked {
            governor = address(this);
            pauseGuardian = address(this);
        }

    }

    function initializeStorage() override external {
        if (lastAccrualTime != 0) revert AlreadyInitialized();
        lastAccrualTime = getNowInternal();
    }


    function getNowInternal() virtual internal view returns (uint40) {
        if (block.timestamp >= 2**40) revert TimestampTooLarge();
        return uint40(block.timestamp);
    }



}