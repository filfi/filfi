// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./FilfiMainInterface.sol";
// import "./v0.8/MinerAPI.sol";
// import "./v0.8/types/MinerTypes.sol";
import { MinerAPI } from "@zondax/filecoin-solidity/contracts/v0.8/MinerAPI.sol";
import { MinerTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/MinerTypes.sol";
import { CommonTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/cbor/BigIntCbor.sol";

contract Filfi is FilfiMainInterface {

    using BigIntCBOR for BigInt;
    address public override immutable governor;

    address public override immutable pauseGuardian;

    event Logger(BigInt msg);

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

    function getAvailableBalance() public returns (MinerTypes.GetAvailableBalanceReturn memory) {
        return MinerAPI.getAvailableBalance(bytes("t01064"));
    }

    function changeBeneficiary() public {
        MinerTypes.ChangeBeneficiaryParams memory params;
        BigInt memory nq =  BigInt(hex'1000', false);
        params.new_quota = nq;
        params.new_expiration = 1000;
        params.new_beneficiary = bytes("0x47C1Cbb1D676B4464c19C5c58deaA50bA468C69B");
        MinerAPI.changeBeneficiary(bytes("t01823"), params);
    }
    
    function getAvailableBalance(string memory target) public returns (BigInt memory) {
        MinerTypes.GetAvailableBalanceReturn memory r = MinerAPI.getAvailableBalance(bytes(target));
        emit Logger(r.available_balance);
        return r.available_balance;
    }
    
    function test(string memory tmp) public pure returns (string memory) {
        return tmp;
    }

}