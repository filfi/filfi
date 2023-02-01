// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./FilfiMainInterface.sol";


abstract contract FilfiUtil is FilfiMainInterface {

    /**
     * @notice Get the current block timestamp, with a protection against overflow
     */
    function getNowInternal() virtual override internal view returns (uint40) {
        if (block.timestamp >= 2**40) revert TimestampTooLarge();
        return uint40(block.timestamp);
    }

    /**
     * @notice accrue interest of the account
     */
    function accrueAccount(address account) internal{

    }

    /**
     * @notice update user Supply balance of the account
     */
    function updateUserAccountSupply(address account, uint amount) internal {

    }



    /**
     * @notice  Call the built-in method to transfer FIl into the contract，
     */
    function doTransferIn(address from, uint amount) internal {
        // todo Call the built-in method to transfer FIl into the contract

    }

    

    /**
     * @notice Update the user's account
     */
    function updateUserAccount(address from,UserAccount memory user) internal {

    }


    /**
     * @notice update user Interest
     */

    function updateUserInterest(address account,uint amount) internal{
        
    }

    /**
     * @notice update user supply balance
     */
    function updateUserAccountWithdraw(address account,uint amount) internal{
    }

    /**
     * @notice Call the built-in method to transfer FIl from the contract to wallet，
     */
    function doTransferOut(address to, uint amount) internal {
        // bool success = transfer(address(this),to, amount);
        // if (!success) revert TransferOutFailed();
        // todo Call the built-in method to transfer FIl from the contract to wallet

    }

    /**
     * @notice update user Borrow balance
     */
    function updateUserAccountBorrow(address account,uint amount) internal{
        
    }

        /**
     * @notice update user Repay balance
     */

    function updateUserAccountRepay(address account,uint amount) internal{

    }

    /**
     * @notice getAssetInfoByMiner use to get asset info by miner
     */

    function getAssetInfoByMiner(address miner) internal view returns(NodeAsset memory){
        
    }

    /**
     * @notice update user node asset
     */
    function updateUserNodeAsset(address account,NodeAsset  memory assetInfo) internal{

        
    }

    /**
     * @notice update user account pledge balance
     */
    function updateUserAccountPledge(address account,NodeAsset memory assetInfo) internal{
        
    }

    /**
     * @notice update user account pledge balance and delete node asset
     */
    function updateUserAccountUnPledge(address account,address miner) internal{

        
    }

    /**
     * @notice update user account pledge balance and delete node asset
     */
    function checkCanUpdatePledgeScale(address account,NodeAsset memory assetInfo) internal view{
    }

}