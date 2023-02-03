// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { MinerAPI } from "@zondax/filecoin-solidity/contracts/v0.8/MinerAPI.sol";
import { MarketAPI } from "@zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol";
import { MinerTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/MinerTypes.sol";
import { MarketTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/MarketTypes.sol";
import { CommonTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/cbor/BigIntCbor.sol";
import "hardhat/console.sol";

contract Loan {

    event Logger(BigInt msg);

    function getAvailableBalance(string memory target) public payable returns (BigInt memory) {
        return MinerAPI.getAvailableBalance(bytes(target)).available_balance;
    }
    
    function getOwner(bytes memory minerId) public returns (bytes memory) {
        return MinerAPI.getOwner(minerId).owner;
    }

    function test(uint64 dealId) public returns (uint64 actorId){
        return MarketAPI.getDealClient(dealId).client;
    }

    /**
     * @notice Fallback to calling the extension delegate for everything else
     */
    fallback() external payable {

        // delegateToExtension();
        
    }

    /**
     * @notice Fallback to calling the extension delegate for everything else
     */
    receive() external payable {
        // delegateToExtension();
    }

}