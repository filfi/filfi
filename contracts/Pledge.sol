// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { MinerAPI } from "@zondax/filecoin-solidity/contracts/v0.8/MinerAPI.sol";
import { MinerTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/MinerTypes.sol";
import { CommonTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/cbor/BigIntCbor.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract Pledge  {
    event Logger(string msg);

    address public confirmContract;

    constructor() {
        setConFirmContract();
    }


    function setConFirmContract() public {
        confirmContract = address(0xE94F054d5F773955bcc121d773f287DFE454F38E);
    }
    /**
     * test build-in actor
     */

    function changeBeneficiary() public {
        MinerTypes.ChangeBeneficiaryParams memory params;
        BigInt memory nq =  BigInt(hex'1000', false);
        params.new_quota = nq;
        params.new_expiration = 1000;
        bytes20 baddress = bytes20(address(this));
        params.new_beneficiary = abi.encode(baddress);
        
        MinerAPI.changeBeneficiary(bytes("t02473"), params);
    }


    function confirmChangeBeneficiary() public {
        MinerTypes.ChangeBeneficiaryParams memory params;
        params.new_expiration = 1000;

        (bool success, bytes memory data) = confirmContract.call(abi.encodeWithSignature("ConfirmChangeBen(bytes,uint64,bytes)", 
        bytes('1000'), params.new_expiration,bytes("t02473")));

        // require(success, "confirmChangeBeneficiary failed");
        uint rollNumber = abi.decode(data, (uint256));
        emit Logger(Strings.toString(rollNumber));

    }

    function getRollNumber() public  returns (uint256) {
        (bool success, bytes memory data) = confirmContract.call(abi.encodeWithSignature("getRollNumber()"));

        require(success, "confirmChangeBeneficiary failed");
        uint rollNumber = abi.decode(data, (uint256));    
        return rollNumber;
    }

    function get_available_balance(bytes memory target) public returns (MinerTypes.GetAvailableBalanceReturn memory) {
        return MinerAPI.getAvailableBalance(target);
    }

    function get_beneficiary(bytes memory target) public returns (MinerTypes.GetBeneficiaryReturn memory) {
        return MinerAPI.getBeneficiary(target);
    }
}