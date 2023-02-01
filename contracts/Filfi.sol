// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./FilfiMainInterface.sol";
import "./FilfiUtil.sol";
import { MinerAPI } from "@zondax/filecoin-solidity/contracts/v0.8/MinerAPI.sol";
import { MinerTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/MinerTypes.sol";
import { CommonTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/cbor/BigIntCbor.sol";

contract Filfi is FilfiUtil {

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
     * @notice Get the current miner available balance
     */
    function getAvailableBalance() public returns (MinerTypes.GetAvailableBalanceReturn memory) {
        return MinerAPI.getAvailableBalance(bytes("t01064"));
    }

    /**
     * @notice Call the miner's change beneficiary method
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
     * @notice Get the current miner available balance
     */
    function getAvailableBalance(string memory target) public returns (BigInt memory) {
        MinerTypes.GetAvailableBalanceReturn memory r = MinerAPI.getAvailableBalance(bytes(target));
        emit Logger(r.available_balance);
        return r.available_balance;
    }
    
    function test(string memory tmp) public pure returns (string memory) {
        return tmp;
    }

    /**
     * @notice Deposit funds into the contract to provide liquidity and obtain income.
    */
    function supply( uint amount) override external {
        if (amount == 0) return;
        // todo  Call the built-in method to transfer FIl into the contract， 
        doTransferIn(msg.sender, amount);

        accrueAccount(msg.sender);
        emit Supply(msg.sender,address(this), amount);
        updateUserAccountSupply(msg.sender, amount);
    }

    /**
     * @notice withdraw accrued  to wallet
     */
    function interestWithdraw (uint amount) override external {
        if (amount == 0) return;
        accrueAccount(msg.sender);
        updateUserInterest(msg.sender, amount);
        doTransferOut(msg.sender, amount);
        emit InterestWithdraw(msg.sender, amount);    
    }

    /**
     * @notice Transfer tokens out of the market
     */
    function withdraw(uint amount) override external {
        if (amount == 0) return;
        accrueAccount(msg.sender);
        
        updateUserAccountWithdraw(msg.sender, amount);
        doTransferOut(msg.sender, amount);
        emit Withdraw(address(this), msg.sender, amount);
    }

    /**
     * @notice Borrow FIL from the contract
     */
    function borrow(uint amount) override external {
        if (amount == 0) return;
        accrueAccount(msg.sender);
        updateUserAccountBorrow(msg.sender, amount);
        doTransferOut(msg.sender, amount);
        emit Borrow(msg.sender, amount);    
    }

    /**
     * @notice Repay FIL to the contract
     */
    function repay(uint amount) override external {
        if (amount == 0) return;
        doTransferIn(msg.sender, amount);
        accrueAccount(msg.sender);
        updateUserAccountRepay(msg.sender, amount);
        emit Repay(msg.sender, amount);
    }

    /**
     * @notice pledge miner to the contract
     */
    function pledge(address miner,uint amount) override external {
        if (amount == 0) return;
        changeBeneficiary();

        NodeAsset memory node =  nodeAssets[msg.sender][miner];
        require(node.miner==address(0), "miner already exist");

        NodeAsset memory assetInfo = getAssetInfoByMiner(miner);
        assetInfo.pledgeScale= 0 ;
        
        updateUserNodeAsset(msg.sender, assetInfo);
        updateUserAccountPledge(msg.sender, assetInfo);
        emit Pledge(msg.sender, miner, miner);
    }

    /**
     * @notice change pledge miner  scale to the contract,This operation will 
     *affect the miner's loanable balance and the entire user's loanable balance
     */
    function changePledgeScale(address miner,uint32 scale) override external {
        if (scale == 0) return;

        NodeAsset memory node =  nodeAssets[msg.sender][miner];
        require(node.miner!=address(0), "miner not exist");
        node.pledgeScale = scale;

        checkCanUpdatePledgeScale(msg.sender,node);
        
        updateUserNodeAsset(msg.sender, node);
        updateUserAccountPledge(msg.sender, node);
        emit Pledge(msg.sender, miner, miner);
    }

    /**
     * @notice unpledge miner from the contract
     */
    function unpledge(address miner) override external {
        changeBeneficiary();
        // if (!ret) revert ChangeBeneficiaryFailed();

        accrueAccount(msg.sender);
        updateUserAccountUnPledge(msg.sender, miner);

        emit Unpledge(msg.sender, miner, miner);    
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