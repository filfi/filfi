// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./FilfiMainInterface.sol";

contract Filfi is FilfiMainInterface {

    address public override immutable governor;

    address public override immutable pauseGuardian;
    address public immutable baseToken;

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


    function supply( uint amount) override external {
        _supply(msg.sender, amount);
    }

    // internal supply  function
    function _supply(address from, uint amount) internal {
        if (amount == 0) return;
        doTransferIn( from, amount);

        _accrue();
        _updateUserAccount(from, amount);
        emit Supply(from, amount);
    }

    function doTransferIn(address from, uint amount) internal {
        bool success = baseToken.transferFrom(from, address(this), amount);
        if (!success) revert TransferInFailed();
    }


    function _updateUserAccount(address from,uint amount) internal {
        UserAccount storage userAccount = userAccounts[from];
        userAccount.principal += int(amount);
        userAccount.totalAccrued += uint56(amount);
        userAccount.accrued += uint56(amount);
        userAccount.lastAccrualTime = lastAccrualTime;
    }




    // 计算收益
    function _accrue() internal {

    }

    function withdraw(uint amount) override external {
        _withdraw(msg.sender, msg.sender, amount);
    }

    function _withdraw(address from, address to, uint amount) internal {
        if (amount == 0) return;
        _accrue();
        _updateUserAccount(from, amount);
        doTransferOut(to, amount);
        emit Withdraw(from, to, amount);
    }

    function doTransferOut(address to, uint amount) internal {
        bool success = baseToken.transfer(to, amount);
        if (!success) revert TransferOutFailed();
    }


}