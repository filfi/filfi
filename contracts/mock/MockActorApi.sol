// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


contract MockActorApi {
    
    function transferFrom(address src, address dst, uint256 amount) external returns (bool) {
        return true;
    }

    function changeBeneficiary(address from, address miner,address to) external returns (bool) {
        return true;
    }


}
