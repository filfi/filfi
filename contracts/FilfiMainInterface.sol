// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./FilfiConfiguration.sol";
import "./FilfiStorage.sol";
import "./FilfiMath.sol";

abstract contract FilfiMainInterface is FilfiConfiguration, FilfiStorage, FilfiMath {

    error AlreadyInitialized();
    error TimestampTooLarge();

    uint64 internal constant FACTOR_SCALE = 1e18;

    uint64 internal constant MAX_COLLATERAL_FACTOR = FACTOR_SCALE;

    uint8 internal constant PAUSE_SUPPLY_OFFSET = 0;
    uint8 internal constant PAUSE_TRANSFER_OFFSET = 1;
    uint8 internal constant PAUSE_WITHDRAW_OFFSET = 2;
    uint8 internal constant PAUSE_ABSORB_OFFSET = 3;
    uint8 internal constant PAUSE_BUY_OFFSET = 4;

    uint64 internal constant SECONDS_PER_YEAR = 31_536_000;

    function hasPermission(address owner, address manager) public view returns (bool) {
        return owner == manager || isAllowed[owner][manager];
    }

    function governor() virtual external view returns (address);
    function pauseGuardian() virtual external view returns (address);

    function initializeStorage() virtual external;

}