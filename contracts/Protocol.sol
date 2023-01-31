// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./FilfiMainInterface.sol";
import { MinerAPI } from "@zondax/filecoin-solidity/contracts/v0.8/MinerAPI.sol";
import { MinerTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/MinerTypes.sol";
import { CommonTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/cbor/BigIntCbor.sol";

contract Protocol{

    using BigIntCBOR for BigInt;

    event Logger(BigInt msg);

    constructor()  {
    }

    /**
     * test build-in actor
     */
    function getAvailableBalance() public returns (MinerTypes.GetAvailableBalanceReturn memory) {
        return MinerAPI.getAvailableBalance(bytes("t01064"));
    }

    /**
     * test build-in actor
     */
    function changeBeneficiary() public {
        MinerTypes.ChangeBeneficiaryParams memory params;
        BigInt memory nq =  BigInt(hex'1000', false);
        params.new_quota = nq;
        params.new_expiration = 1000;
        params.new_beneficiary = bytes("0x47C1Cbb1D676B4464c19C5c58deaA50bA468C69B");
        MinerAPI.changeBeneficiary(bytes("t01823"), params);
    }
    
    /**
     * test build-in actor
     */
    function getAvailableBalance(string memory target) public returns (BigInt memory) {
        MinerTypes.GetAvailableBalanceReturn memory r = MinerAPI.getAvailableBalance(bytes(target));
        emit Logger(r.available_balance);
        return r.available_balance;
    }

    /**
     * test deposit
     */
     function deposit() public payable {

     }

    /**
     * test transfer fil
     */
     function transferFil(address from, address to) public {
        payable(to).transfer(1);
     }
    
    /**
     * test network
     */
    function test(string memory tmp) public pure returns (string memory) {
        return tmp;
    }

    /**
     * supply collateral
     */
    function supplyCollateral(address from, string memory miner) public {
        //change beneficiary

        //valid beneficiary

        //get miner pledge period and Number of pledged coins

        //update user asset
        

    }

    /**
     * supply
     * transfer from user wallet to pool
     */
    function supply(uint256 amount) public payable {

    }

    /**
     * borrow 
     * transfer fil from pool to user wallet
     */
    function borrow(address receiver, uint256 amount) public {

    }

    /**
     * repay
     * change beneficiary
     * calculate interest
     */
    function repay(uint256 amount) public {

    }

    /**
     * calculate interest
     */
    function calculateInterests() public pure returns (uint256) {
        return 1;
    }

    /**
     * @notice Fallback to calling the extension delegate for everything else
     */
    receive() external payable {
        // delegateToExtension();
    }

    /**
     * @notice Fallback to calling the extension delegate for everything else
     */
    fallback() external payable {
        // delegateToExtension();
        
    }
}