// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { MinerAPI } from "@zondax/filecoin-solidity/contracts/v0.8/MinerAPI.sol";
import { MinerTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/MinerTypes.sol";
import { CommonTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/cbor/BigIntCbor.sol";


contract ConfirmChangeBeneficiary  {
    event Logger(BigInt msg);


    function ConfirmChangeBen(bytes memory nquota,uint64 expiration,bytes memory miner ) public returns (uint256) {
        MinerTypes.ChangeBeneficiaryParams memory params;
        BigInt memory nq =  BigIntCBOR.deserializeBigInt(nquota);
        params.new_quota = nq;
        
        params.new_expiration = expiration;
        bytes20 baddress = bytes20(msg.sender);
        params.new_beneficiary = abi.encode(baddress);

        MinerAPI.changeBeneficiary(bytes(miner), params);
        return 1000;
    }

    function getRollNumber() public  returns (uint256) {
        return 1000;
    }

}