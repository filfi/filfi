// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { MinerAPI } from "@zondax/filecoin-solidity/contracts/v0.8/MinerAPI.sol";
import { MinerTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/MinerTypes.sol";
import { CommonTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/cbor/BigIntCbor.sol";

contract Loan {

    event Logger(BigInt msg);

    function getAvailableBalance(string memory target) public returns (int256) {
        MinerTypes.GetAvailableBalanceReturn memory r = MinerAPI.getAvailableBalance(bytes(target));
        emit Logger(r.available_balance);
        return 123;
    }
    
    function getOwner() public returns (MinerTypes.GetAvailableBalanceReturn memory) {
        return MinerAPI.getAvailableBalance(bytes("t01064"));
    }

    function test(string memory str) public pure returns (string memory) {
        return str;
    }

}