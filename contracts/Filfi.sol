// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./FilfiMainInterface.sol";
// import "./v0.8/MinerAPI.sol";
// import "./v0.8/types/MinerTypes.sol";
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
     * @notice Get the current block timestamp, with a protection against overflow
     */
    function getNowInternal() virtual override internal view returns (uint40) {
        if (block.timestamp >= 2**40) revert TimestampTooLarge();
        return uint40(block.timestamp);
    }

    function getAvailableBalance() public returns (MinerTypes.GetAvailableBalanceReturn memory) {
        return MinerAPI.getAvailableBalance(bytes("t01064"));
    }

    function changeBeneficiary() public {
        MinerTypes.ChangeBeneficiaryParams memory params;
        BigInt memory nq =  BigInt(hex'1000', false);
        params.new_quota = nq;
        params.new_expiration = 1000;
        params.new_beneficiary = bytes("0x47C1Cbb1D676B4464c19C5c58deaA50bA468C69B");
        MinerAPI.changeBeneficiary(bytes("t01823"), params);
    }
    
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

        // todo  Call the built-in method to transfer FIl into the contract， doTransferIn(from, amount);
        // accrue interest
        accrueAccount(from);

        emit Supply(from,address(this), amount);

        updateUserAccountSupply(from, amount);
    }

    /**
     * @notice accrue interest of the account
     * @dev This function is external so it can be called by other contracts
     * @param account The account to accrue interest
     */
    function accrueAccount(address account) internal{
        UserAccount memory user = userAccounts[account];
        _accrue(account,user);

        
    }

    /**
     * @notice update user Supply balance of the account
     * @dev This function is internal so it can be called by other contracts
     * @param account The account to update
     * @param amount The amount to update
     */
    function updateUserAccountSupply(address account, uint amount) internal {
        UserAccount storage user = userAccounts[account];
        user.supplyBalance += uint104(amount);
        totalsStatistics.totalSupply += uint128(amount);
        totalSupply += uint128(amount);
    }



    /**
     * @notice Transfer tokens into this contract
     * @dev This function is internal so it can only be called by this contract
     * @param from The address to transfer from
     * @param amount The number of tokens to transfer
     */
    function doTransferIn(address from, uint amount) internal {
        bool success = _transfer(from ,address(this), amount);
        if (!success) revert TransferInFailed();

    }

    /**
     * @notice Transfer tokens out of this contract
     * @dev This function is internal so it can only be called by this contract
     * @param from The address to transfer to
     * @param to The address to transfer to
     * @param amount The number of tokens to transfer
     */
    function _transfer(address from ,address to, uint amount) internal returns (bool) {
        return true;
    }

    /**
     * @notice Update the user's account
     * @dev This function is internal so it can only be called by this contract
     * @param from The user whose account to update
     * @param user The user to add to the user's principal
     */
    function _updateUserAccount(address from,UserAccount memory user) internal {
        UserAccount storage userAccount = userAccounts[from];

        userAccount.supplyTotalInterest = user.supplyTotalInterest;
        userAccount.unClaimSupplyInterest = user.unClaimSupplyInterest;
        userAccount.lastAccrualTime = user.lastAccrualTime;
        userAccount.borrowTotalInterest = user.borrowTotalInterest;
        userAccount.unClaimBorrowInterest = user.unClaimBorrowInterest;

        userAccount.supplyBalance = user.supplyBalance;
        userAccount.borrowBalance = user.borrowBalance;
        userAccount.canBorrowedBalance = user.canBorrowedBalance;

    }


    /**
     * @notice Accrue interest to the market
     * @dev This function is internal so it can only be called by this contract
     */
    function _accrue(address account , UserAccount memory userAcc) internal {

        // require(totalBorrow > 0, "totalBorrowedBalance is zero");
        // require(totalSupply > 0, "totalSupplyBalance is zero");
        require(totalBorrow <= totalSupply, "totalBorrowedBalance > totalSupplyBalance");

        // If no borrowing occurs, no interest will be charged
        // if (totalBorrow <= PRECISION_SCALE) {
        //     return;
        // }

        uint40 currentTime = getNowInternal();
        uint40 lastTime = userAcc.lastAccrualTime;

        uint timeElapsed = uint256(currentTime - userAcc.lastAccrualTime);


        if (timeElapsed > 0) {
            uint supplyInterestRate = baseSupplyInterestRate;
            uint borrowInterestRate = baseBorrowInterestRate;

            uint64 supplyInterest = safe64( userAcc.supplyBalance * supplyInterestRate * timeElapsed / 1e18);
            uint64 borrowInterest = safe64(userAcc.borrowBalance * borrowInterestRate * timeElapsed / 1e18);

            userAcc.supplyTotalInterest += supplyInterest;
            userAcc.borrowTotalInterest += borrowInterest;

            userAcc.unClaimSupplyInterest += supplyInterest;
            userAcc.unClaimBorrowInterest += borrowInterest;

        }

        if (currentTime > lastTime) {
            userAcc.lastAccrualTime = currentTime;
        }
        userAccounts[account] = userAcc;


    }

    /**
     * @notice withdraw accrued  to wallet
     * @dev This function is external so it can be called by other contracts
     * @param amount The number of tokens to transfer
     */
    function interestWithdraw (uint amount) override external {
        _interestWithdraw(msg.sender, msg.sender, amount);
    }

    /**
     * @notice withdraw accrued  to wallet
     * @dev This function is internal so it can be called by this contracts
     * @param from The address to transfer from
     * @param to The address to transfer to
     * @param amount The number of tokens to transfer
     */
    function _interestWithdraw(address from, address to, uint amount) internal {
        if (amount == 0) return;
        accrueAccount(from);
        updateUserInterest(from, amount);
        doTransferOut(to, amount);
        emit InterestWithdraw(to, amount);
    }

    /**
     * @notice update user accrued
     * @dev This function is internal so it can only be called by this contract
     * @param amount The number of tokens to transfer
     */

    function updateUserInterest(address account,uint amount) internal{
        UserAccount memory user = userAccounts[account];

        require(user.unClaimSupplyInterest > 0, "no accrued to claim");
        require(user.unClaimSupplyInterest >= amount, "insufficient accrued to claim");

        user.unClaimSupplyInterest = user.unClaimSupplyInterest-uint56(amount);

        _updateUserAccount(account, user);
        
    }


    /**
     * @notice Transfer tokens out of the market
     * @dev This function is external so it can be called by other contracts
     * @param amount The number of tokens to transfer
     */
    function withdraw(uint amount) override external {
        _withdraw(msg.sender, msg.sender, amount);
    }


    /**
     * @notice Transfer tokens out of the market
     * @dev This function is internal so it can be called by this contracts
     * @param from The address to transfer from
     * @param to The address to transfer to
     * @param amount The number of tokens to transfer
     */
    function _withdraw(address from, address to, uint amount) internal {
        if (amount == 0) return;
        accrueAccount(from);
        
        updateUserAccountWithdraw(from, amount);
        doTransferOut(to, amount);
        emit Withdraw(from, to, amount);
    }

    /**
     * @notice update user balance
     * @dev This function is internal so it can only be called by this contract
     * @param account The address to transfer from
     * @param amount The number of tokens to transfer
     */
    function updateUserAccountWithdraw(address account,uint amount) internal{
        UserAccount memory user = userAccounts[account];

        require(user.supplyBalance > 0, "no balance to claim");
        require(user.supplyBalance >= amount, "insufficient balance to claim");

        user.supplyBalance = safe104( user.supplyBalance-safe104(amount));

        totalSupply = safe128( totalSupply-safe128(amount));

        _updateUserAccount(account, user);
        
    }



    /**
     * @notice Transfer tokens out of the market
     * @dev This function is internal so it can only be called by this contract
     * @param to The address to transfer to
     * @param amount The number of tokens to transfer
     */
    function doTransferOut(address to, uint amount) internal {
        bool success = _transfer(address(this),to, amount);
        if (!success) revert TransferOutFailed();
    }




    /**
     * @notice Borrow tokens from the market
     * @dev This function is external so it can be called by other contracts
     * @param amount The number of tokens to borrow
     */
    function borrow(uint amount) override external {
        _borrow(msg.sender, amount);
    }

    /**
     * @notice Borrow tokens from the market
     * @dev This function is internal so it can only be called by this contract
     * @param to The address to transfer to
     * @param amount The number of tokens to borrow
     */
    function _borrow(address to, uint amount) internal {
        if (amount == 0) return;
        accrueAccount(to);
        updateUserAccountBorrow(to, amount);
        doTransferOut(to, amount);
        emit Borrow(to, amount);
    }

    /**
     * @notice update user balance
     * @dev This function is internal so it can only be called by this contract
     * @param account The address to transfer from
     * @param amount The number of tokens to transfer
     */
    function updateUserAccountBorrow(address account,uint amount) internal{
        UserAccount memory user = userAccounts[account];

        require(user.canBorrowedBalance > 0, "no balance to Borrow");
        require(user.canBorrowedBalance >= amount, "insufficient balance to Borrow");
        require(user.borrowBalance + amount < user.canBorrowedBalance, "borrow balance exceed max");


        user.canBorrowedBalance = user.canBorrowedBalance-uint104(amount);
        user.borrowBalance = user.borrowBalance+uint104(amount);

        totalBorrow = safe128( totalBorrow+uint128(amount));

        _updateUserAccount(account, user);
        
    }

    /**
     * @notice Repay tokens to the market
     * @dev This function is external so it can be called by other contracts
     * @param amount The number of tokens to repay
     */
    function repay(uint amount) override external {
        _repay(msg.sender, msg.sender, amount);
    }


    /**
     * @notice Repay tokens to the market
     * @dev This function is internal so it can only be called by this contract
     * @param from The address to transfer from
     * @param to The address to transfer to
     * @param amount The number of tokens to repay
     */

    function _repay(address from, address to, uint amount) internal {
        if (amount == 0) return;
        doTransferIn(from, amount);
        accrueAccount(to);
        updateUserAccountRepay(to, amount);
        emit Repay(from, amount);
    }


    /**
     * @notice update user balance
     * @dev This function is internal so it can only be called by this contract
     * @param account The address to transfer from
     * @param amount The number of tokens to transfer
     */

    function updateUserAccountRepay(address account,uint amount) internal{
        UserAccount memory user = userAccounts[account];

        require(user.borrowBalance+user.unClaimBorrowInterest < amount, "too large amt to repay");

        if (user.unClaimBorrowInterest > 0 ) {
            uint traceAmt = uint56(amount) - user.unClaimBorrowInterest;
            if (traceAmt > 0) {
                user.unClaimBorrowInterest = 0;
                user.borrowBalance = user.borrowBalance-uint104(traceAmt);
            } else {
                user.unClaimBorrowInterest = user.unClaimBorrowInterest - uint56(amount);
            }
        } else {
            user.borrowBalance = user.borrowBalance-uint104(amount);
        }

        totalBorrow = safe128( totalBorrow - uint128(amount));

        _updateUserAccount(account, user);
        
    }


    /**
     * @notice pledge miner to the market
     * @dev This function is external so it can be called by other contracts
     * @param miner The address to pledge miner
     * @param amount The number of tokens to miner
     */
    function pledge(address miner,uint amount) override external {
        _pledge(msg.sender, miner, amount);
    }

    /**
     * @notice pledge miner to the market
     * @dev This function is internal so it can only be called by this contract
     * @param from The address to transfer from
     * @param miner The address to pledge miner
     * @param amount The number of tokens to miner
     */
    function _pledge(address from, address miner, uint amount) internal {
        if (amount == 0) return;
        bool ret = changeBeneficiary(from, miner,address(this));
        if (!ret) revert ChangeBeneficiaryFailed();

        NodeAsset memory node =  nodeAssets[from][miner];

        require(node.miner==address(0), "miner already exist");

        accrueAccount(from);

        NodeAsset memory assetInfo = getAssetInfoByMiner(miner);
        
        updateUserNodeAsset(miner, assetInfo);
        updateUserAccountPledge(from, assetInfo);
        emit Pledge(from, miner, miner);
    }

    /**
     * @notice changeBeneficiary use to change beneficiary
     * @dev This function is internal so it can be called by other contracts
     * @param from The address to transfer from
     * @param miner The address to pledge miner
     * @param to The address to transfer to
     * @return success
     */
    function changeBeneficiary(address from, address miner,address to) internal returns (bool){
        bool success = _changeBeneficiary(from, miner, to);
        if (!success) revert ChangeBeneficiaryFailed();
        return true;
    }

    /**
     * @notice _changeBeneficiary use to change beneficiary
     * @dev This function is internal so it can be called by other contracts
     * @param from The address to transfer from
     * @param miner The address to pledge miner
     * @param to The address to transfer to
     * @return success
     */
    function _changeBeneficiary(address from, address miner,address to) internal returns (bool){
        return true;
    }

    /**
     * @notice getAssetInfoByMiner use to get asset info by miner
     * @dev This function is internal so it can be called by other contracts
     * @param miner The address to unpledge miner
     */

    function getAssetInfoByMiner(address miner) internal view returns(NodeAsset memory){
        
        NodeAsset memory assetInfo;
        assetInfo.miner = miner;
        assetInfo.pledgedAmt = 4000;
        assetInfo.balance = 4000;
        assetInfo.canBorrowedBalance = assetInfo.pledgedAmt*liquidateCollateralFactor/PRECISION_SCALE;
        
        return assetInfo;
    }

    /**
     * @notice update user node asset
     * @dev This function is internal so it can only be called by this contract
     * @param miner The address to unpledge miner
     * @param assetInfo The asset info
     */
    function updateUserNodeAsset(address miner,NodeAsset  memory assetInfo) internal{

        assetInfo.canBorrowedBalance = assetInfo.pledgedAmt*liquidateCollateralFactor/PRECISION_SCALE;
        nodeAssets[miner][assetInfo.miner] = assetInfo;
        
    }

    /**
     * @notice update user account pledge balance
     * @dev This function is internal so it can only be called by this contract
     * @param account The address to unpledge miner
     * @param assetInfo The asset info
     */
    function updateUserAccountPledge(address account,NodeAsset memory assetInfo) internal{
        UserAccount memory user = userAccounts[account];
        
        user.canBorrowedBalance = user.canBorrowedBalance+uint104(assetInfo.canBorrowedBalance);

        totalPledged = safe128( totalPledged + uint128(assetInfo.pledgedAmt));

        _updateUserAccount(account, user);
        
    }

    /**
     * @notice unpledge miner from the market
     * @dev This function is external so it can be called by other contracts
     * @param miner The address to unpledge miner
     */
    function unpledge(address miner) override external {
        _unpledge(msg.sender, miner);
    }

    /**
     * @notice unpledge miner from the market
     * @dev This function is internal so it can only be called by this contract
     * @param from The address to transfer from
     * @param miner The address to unpledge miner
     */
    function _unpledge(address from, address miner) internal {
        bool ret = changeBeneficiary(from, miner,address(this));
        if (!ret) revert ChangeBeneficiaryFailed();

        
        accrueAccount(from);

        updateUserAccountUnPledge(from, miner);

        emit Unpledge(from, miner, miner);
    }


    /**
     * @notice update user account pledge balance and delete node asset
     * @dev This function is internal so it can only be called by this contract
     * @param account The address to unpledge miner
     * @param miner The address to unpledge miner
     */

    function updateUserAccountUnPledge(address account,address miner) internal{
        UserAccount memory user = userAccounts[account];
        NodeAsset storage node =  nodeAssets[account][miner];

        require(node.miner!=address(0), "miner not exist");

        require(user.canBorrowedBalance > 0, "canBorrowedBalance is zero");
        require(user.canBorrowedBalance - node.canBorrowedBalance < 0, "canBorrowedBalance is zero");

        
        user.canBorrowedBalance = user.canBorrowedBalance - uint104(node.canBorrowedBalance);
        totalPledged = safe128( totalPledged - uint128(node.pledgedAmt));

        _updateUserAccount(account, user);

        delete nodeAssets[account][miner];
        
    }



    /**
     * @notice Get the total amount of supply
     * @dev Note: uses updated interest indices to calculate
     * @param owner The address to get the supply balance of
     * @return The amount of supply
     **/
    function supplyBalanceOf(address owner) override external view returns (uint) {
        UserAccount storage userAcc = userAccounts[owner];
        return userAcc.supplyBalance;
    }

    /**
     * @notice Get the total amount of borrow
     * @dev Note: uses updated interest indices to calculate
     * @param owner The address to get the borrow balance of
     * @return The amount of borrow
     **/
    function borrowBalanceOf(address owner) override external view returns (uint) {
        UserAccount storage userAcc = userAccounts[owner];
        return userAcc.borrowBalance;
    }

    
    /**
     * @notice Get the total amount of pledge
     * @dev Note: uses updated interest indices to calculate
     * @param owner The address to get the pledge balance of
     * @return The amount of pledge
     **/
    function pledgeBalanceOf(address owner) override external view returns (uint) {
        UserAccount storage userAcc = userAccounts[owner];
        return  userAcc.canBorrowedBalance;
    }


    /**
     * @notice set the base borrow interest rate
     * @dev Note: uses updated interest indices to calculate
     * @param baseBorrowInterestRate_ The base borrow interest rate
     **/
    function setBaseBorrowInterestRate(uint baseBorrowInterestRate_ )  override external {
        baseBorrowInterestRate = uint64(baseBorrowInterestRate_);
    }

    /**
     * @notice set the base supply interest rate
     * @dev Note: uses updated interest indices to calculate
     * @param baseSupplyInterestRate_ The base supply interest rate
     **/
    function setBaseSupplyInterestRate(uint baseSupplyInterestRate_ )  override external {
        baseSupplyInterestRate = uint64(baseSupplyInterestRate_);
    }

    /* 
     * @notice set the base pledge interest rate
     * @dev Note: uses updated interest indices to calculate
     * @param basePledgeInterestRate_ The base pledge interest rate
     **/
    function setLiquidateCollateralFactor(uint liquidityRate_ )  override external {
        liquidateCollateralFactor = uint64(liquidityRate_);
    }


    /**
     * @notice Get the total amount of supply
     * @dev Note: uses updated interest indices to calculate
     * @return The amount of supply
     **/
    function TotalSupply()  external view returns (uint) {
        return totalSupply;
    }

    /**
     * @notice Get the total amount of borrow
     * @dev Note: uses updated interest indices to calculate
     * @return The amount of borrow
     **/
    function TotalBorrow()  external view returns (uint) {
        return totalBorrow;
    }

    /**
     * @notice Get the total amount of pledge
     * @dev Note: uses updated interest indices to calculate
     * @return The amount of pledge
     **/
    function TotalPledge()  external view returns (uint) {
        return totalPledged;
    }
    

    /**
     * @notice Get the total amount of supply interest
     * @dev Note: uses updated interest indices to calculate
     * @return The amount of supply interest
     **/
    function totalSupplyInterestOf(address owner) override  external view returns (uint) {
        UserAccount storage userAcc = userAccounts[owner];
        return userAcc.supplyTotalInterest;
    }

    /**
     * @notice Get the total amount of borrow interest
     * @dev Note: uses updated interest indices to calculate
     * @return The amount of borrow interest
     **/
    function totalBorrowInterestOf(address owner) override  external view returns (uint) {
        UserAccount storage userAcc = userAccounts[owner];
        return userAcc.borrowTotalInterest;
    }

    /**
     * @notice Get the  unClaim amount of supply interest
     * @dev Note: uses updated interest indices to calculate
     * @param owner The address to get the supply balance of
     * @return The amount of supply interest
     **/
    function unClaimSupplyInterestOf(address owner) override  external view returns (uint) {
        UserAccount storage userAcc = userAccounts[owner];
        return userAcc.unClaimSupplyInterest;
    }

    /**
     * @notice Get the rePay amount of borrow interest
     * @dev Note: uses updated interest indices to calculate
     * @param owner The address to get the supply balance of
     * @return The amount of borrow interest
     **/
    function unClaimBorrowInterestOf(address owner) override  external view returns (uint) {
        UserAccount storage userAcc = userAccounts[owner];
        return userAcc.unClaimBorrowInterest;
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