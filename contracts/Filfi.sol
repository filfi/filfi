// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./FilfiMainInterface.sol";
import { MinerAPI } from "@zondax/filecoin-solidity/contracts/v0.8/MinerAPI.sol";
import { MinerTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/MinerTypes.sol";
import { CommonTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/cbor/BigIntCbor.sol";

contract Filfi is FilfiMainInterface {

    using BigIntCBOR for BigInt;
    event Logger(BigInt msg);
    constructor()  {
        unchecked {
            governor = address(this);
            pauseGuardian = address(this);
        }
        baseToken = address(this);
        baseBorrowInterestRate = BASE_BORROW_INTEREST_RATE;
        baseSupplyInterestRate = BASE_SUPPLY_INTEREST_RATE;
        liquidateCollateralFactor = LIQUIDATE_COLLATERAL_FACTOR;
    }

    /**
     * @notice Initialize the market
     */
    function initializeStorage() override external {
        if (lastAccrualTime != 0) revert AlreadyInitialized();
        lastAccrualTime = getNowInternal();
    }

    /**
     * @notice change miner's beneficiary to newBeneficiary
     */
    function changeBeneficiary(bytes memory minerId, bytes memory newBeneficiary) public {
        MinerTypes.ChangeBeneficiaryParams memory params;
        BigInt memory nq =  BigInt(hex'1000', false);
        params.new_quota = nq;
        params.new_expiration = 1000;
        params.new_beneficiary = newBeneficiary;
        MinerAPI.changeBeneficiary(minerId, params);
    }

    /**
     * @notice convert address to bytes     
     */
    function toBytes(address addr) public pure returns (bytes memory b) {
        assembly {
            let m := mload(0x40)
            addr := and(addr, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, addr))
            mstore(0x40, add(m, 52))
            b := m
        }
    }
    
    /**
     * @notice pledge miner to the contract
     */
    function pledge(bytes memory minerBs, string memory minerId) override external {
        NodeAsset memory node =  nodeAssets[msg.sender][minerId];
        // require(node.miner != "", "miner already exist");
        changeBeneficiary(minerBs, toBytes(address(this)));

        // update user node asset
        NodeAsset memory assetInfo;
        assetInfo.pledgeScale= 0;
        assetInfo.minerId = minerId;
        nodeAssets[msg.sender][minerId] = assetInfo;
        
        emit Pledge(msg.sender, address(this), minerId);
    }


    /**
     * @notice Deposit funds into the contract
    */
    function supply(uint104 amount) override external payable {
        if (amount <= 0) return;
        require(msg.value == amount, "supply amount error!");

        UserAccount memory ua = userAccounts[msg.sender];
        if (ua.isUsed) {
            ua.supplyBalance = amount;
        } else {
            ua.supplyBalance += amount;
            ua.lastAccrualTime = getNowInternal();
            ua.canBorrowedBalance = safe64(mulFactor(ua.unClaimSupplyInterest, amount));
            ua.isUsed = true;
        }

        emit Supply(msg.sender,address(this), amount);
    }
    
    /**
     * @notice Transfer tokens out of the market
     */
    function withdraw(uint amount) override external {
        if (amount == 0) return;

        UserAccount memory ua = userAccounts[msg.sender];
        require(!ua.isUsed, "No permission to operate");
        //todo...Determine the current balance
        payable(msg.sender).transfer(amount);

        emit Withdraw(address(this), msg.sender, amount);
    }

    /**
     * @notice Borrow FIL from the contract
     */
    function borrow(uint amount) override external {
        if (amount == 0) return;
        // accrueAccount(msg.sender);
        // updateUserAccountBorrow(msg.sender, amount);
        // doTransferOut(msg.sender, amount);
        emit Borrow(msg.sender, amount);    
    }

    /**
     * @notice Repay FIL to the contract
     */
    function repay(uint amount) override external {
        if (amount == 0) return;
        // doTransferIn(msg.sender, amount);
        // accrueAccount(msg.sender);
        // updateUserAccountRepay(msg.sender, amount);
        emit Repay(msg.sender, amount);
    }

    /**
     * @notice unpledge miner from the contract
     */
    function unpledge(bytes memory minerBs, string memory minerId) override external {
        changeBeneficiary(minerBs, toBytes(msg.sender));
        // if (!ret) revert ChangeBeneficiaryFailed();

        // accrueAccount(msg.sender);
        // updateUserAccountUnPledge(msg.sender, miner);

        emit Unpledge(address(this), msg.sender, minerId);
    }

    /**
     * @notice withdraw accrued  to wallet
     */
    function interestWithdraw(uint amount) override external {
        if (amount == 0) return;
        // accrueAccount(msg.sender);
        // updateUserInterest(msg.sender, amount);
        // doTransferOut(msg.sender, amount);
        emit InterestWithdraw(msg.sender, amount);    
    }

    /**
     * @notice change pledge miner  scale to the contract,This operation will 
     *affect the miner's loanable balance and the entire user's loanable balance
     */
    function changePledgeScale(string memory minerId,uint32 scale) override external {
        if (scale == 0) return;

        NodeAsset memory node =  nodeAssets[msg.sender][minerId];
        // require(node.minerId != "", "miner not exist");
        node.pledgeScale = scale;

        // checkCanUpdatePledgeScale(msg.sender,node);
        
        // updateUserNodeAsset(msg.sender, node);
        // updateUserAccountPledge(msg.sender, node);
        emit Pledge(msg.sender, address(this), minerId);
    }

    /**
     * @notice Get the total amount of supply
     **/
    function supplyBalanceOf(address owner) override external view returns (uint) {
        UserAccount storage userAcc = userAccounts[owner];
        return userAcc.supplyBalance;
    }

    /**
     * @notice Get the total amount of borrow
     **/
    function borrowBalanceOf(address owner) override external view returns (uint) {
        UserAccount storage userAcc = userAccounts[owner];
        return userAcc.borrowBalance;
    }

    /**
     * @notice Get the total amount of pledge
     **/
    function pledgeBalanceOf(address owner) override external view returns (uint) {
        UserAccount storage userAcc = userAccounts[owner];
        return  userAcc.canBorrowedBalance;
    }

    /**
     * @notice set the base borrow interest rate
     **/
    function setBaseBorrowInterestRate(uint baseBorrowInterestRate_ )  override external {
        baseBorrowInterestRate = uint64(baseBorrowInterestRate_);
    }

    /**
     * @notice set the base supply interest rate
     **/
    function setBaseSupplyInterestRate(uint baseSupplyInterestRate_ )  override external {
        baseSupplyInterestRate = uint64(baseSupplyInterestRate_);
    }

    /* 
     * @notice set the base pledge interest rate
     **/
    function setLiquidateCollateralFactor(uint liquidityRate_ )  override external {
        liquidateCollateralFactor = uint64(liquidityRate_);
    }

    /**
     * @notice Get the total amount of supply
     **/
    function TotalSupply()  external view returns (uint) {
        return totalSupply;
    }

    /**
     * @notice Get the total amount of borrow
     **/
    function TotalBorrow()  external view returns (uint) {
        return totalBorrow;
    }

    /**
     * @notice Get the total amount of pledge
     **/
    function TotalPledge()  external view returns (uint) {
        return totalPledged;
    }
    
    /**
     * @notice Get the total amount of supply interest
     **/
    function totalSupplyInterestOf(address owner) override  external view returns (uint) {
        UserAccount storage userAcc = userAccounts[owner];
        return userAcc.supplyTotalInterest;
    }

    /**
     * @notice Get the total amount of borrow interest
     **/
    function totalBorrowInterestOf(address owner) override  external view returns (uint) {
        UserAccount storage userAcc = userAccounts[owner];
        return userAcc.borrowTotalInterest;
    }

    /**
     * @notice Get the  unClaim amount of supply interest
     **/
    function unClaimSupplyInterestOf(address owner) override  external view returns (uint) {
        UserAccount storage userAcc = userAccounts[owner];
        return userAcc.unClaimSupplyInterest;
    }

    /**
     * @notice Get the rePay amount of borrow interest
     **/
    function unClaimBorrowInterestOf(address owner) override  external view returns (uint) {
        UserAccount storage userAcc = userAccounts[owner];
        return userAcc.unClaimBorrowInterest;
    }

    /**
     * @dev Multiply a number by a factor
     */
    function mulFactor(uint n, uint factor) internal pure returns (uint) {
        return n * factor / FACTOR_SCALE;
    }

    /**
     * @notice Get the current block timestamp, with a protection against overflow
     */
    function getNowInternal() virtual override internal view returns (uint40) {
        if (block.timestamp >= 2**40) revert TimestampTooLarge();
        return uint40(block.timestamp);
    }

    /**
     * @notice Fallback to calling the extension delegate for everything else
     */
    fallback() external payable {
        
    }

    /**
     * @notice Fallback to calling the extension delegate for everything else
     */
    receive() external payable {
    }
}