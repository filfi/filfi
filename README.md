# FilFi - free your filecoin assets

An permissionless liquid market for filecoin.  Collateral your nodes and get FILs.


## Background

Building Filecoin nodes requires a large amount of pledging, which has become one of the bottlenecks in the growth of the Filecoin network, and the FIL lending market has been created to a certain extent. The built nodes themselves have a lot of value, including pledged FILs, future rewards, and linear vesting, making them ideal collateral. 

The FilFi protocol expects to release the liquidity of the nodes by collateral their Filecoin assets, lowering the financial barrier for small and medium storage providers to enter this market and adding momentum to the growth of the Filecoin network.

With the upcoming launch of the FVM, which opens up the space for a collateralized lending market, we now have the opportunity to use smart contracts and market-based mechanisms to complete the performance process in a secure and trustworthy manner, with investors contributing liquidity and node-owning builders gaining momentum for continued growth.

The goal of the Filfi project is to create a permissionless liquidity marketplace for the Filecoin community, help small and medium-sized storage providers enter the network, and facilitate the expansion and decentralization of power in the Filecoin network.


## Usecase

- Storage providers need large amounts FIL for pledging when expanding scale, the current practice is that lending occurs based on a relationship of trust.
- People who hold FILs and do not want to sell need a safe and secure way to invest.
- Everyone want to freely participates in a permissionless bilateral market that prices liquidity in a market-based manner.


## Problem

- The core problem of existing collateralized lending market is performance. Lending based on the trust of acquaintances and personal integrity can be fragile and unstable when risk occurs.
- Delivering the owner's private key just for lending is not feasible in practice.
- Both lenders and borrowers want to have free access to the liquid market.
- How can liquidity be priced in a market-based manner?
- The value of the nodes is compounded, including pledged FILs, future reward, linear vesting, which part is pledged and how much？ all requiring very flexible lending options.
- How to handle future reward as the collateraled nodes continue to reward FILs?
- How smart contracts liquidate assets independently？


# Solution

- With FEVM/FVM online,  a trusted fulfillment process is achieved by putting a smart contract in control of the financial part of the node.
- By creating a collateralized lending market that allows anyone to join the market without permission.
- Designing different interest rate models for borrowing and lending and calculate at each block time.
- Distinguish asset types with different asset factors for different asset types to address the different nature of pledged FILs and future rewards.
- Freely adjust the ratio of locked assets for maximum flexibility.

## Actors

### Brrower
- Brrower collateral node assets and brrow FILs.
- The assets that can be collateraled by a node include
  - Pledged FILs
  - Future rewards
- Brrower can adjust the lock-in ratio of the collateral assets at any time.
- Borrower can repay the debt at any time.

### Lender
- Lender provide FIL liquidity  and anyone can join freely without permission.
- Receive interest revenue by lending fil. (scalable to support other on-chain assets on Filecoin)
- Lenders can withdraw their liquidity at any time
- When a brrowser defaults, the smart contract automatically liquidates the collateral and repays the Lender's assets.

### Smart Contract
- Smart contracts deployed on FEVM/FVM, implementing the FilFi protocol.
- FilFi.app is web interface for smart contract.

### DAO 

- DAO is made up of individuals and service providers that offer specific services to DAOs through governance tokens and governance processes.
- Members are independent market participants, not employed.
- Members are divided into different roles. For example, the Governance Coordinator, who chairs the communication and governance process; and members of the Risk Team, who support Filfi governance through financial risk research and drafting proposals for the introduction of new types of collateral and the management of existing collateral.

## Asset Types

There are tow types of collateralizable assets
- Pledged FILs in the node
- Future reward of the node

### Asset Factor

- Reserve Factor. The protocol keep small part of interest income as a reserve for the protocol. The reserves serves as a layer of protection against risks arising in liquidation.
- Collateral Factor. The percentage of assets that can generate the amount borrowed, with the over-collateralized portion being used to protect the lenders from being able to safely recover liquidity.
- Liquidation Factor. Greater than the Collateral Factor, the liquidation is triggered when the value of the assets falls below the value calculated by the liquidation factor.
- Liquidation Penalty. The protocol discourages the occurrence of liquidation and needs to encourage users to actively maintain the healthy operation of the node instead of sitting around waiting for liquidation to occur, so there needs to be some penalty for liquidation events.


## Interest Rate Model
Interest rates are determined by market supply and demand and are related to the utilization of funds. Different interest rate models are used for lending and borrowing.
- The smart contract performs accounting calculations at each block time to update the market interest rate.
- Borrowing rate is a function of the utilization rate of funds.
- The lending rate is a function of the borrowing rate.
- The interest rate models all have segmented inflection points to protect the market from a sudden depletion of liquidity.
- The key coefficients of the interest rate model are determined by the DAO governance process.

## Smart Contracts Module

### Asset Package Module
The Asset Package module holds the basic building blocks of the Filfi protocol.
- Database - risk parameters as well as collateral and debt balances.
- Accounting System - Basic accounting operations for updating the database.
- Asset Package Management - Adjusts locked collateral and debt positions.
- Asset package flow - the ability to transfer, split and consolidate asset packages
These building blocks of asset packages are designed not to be upgraded or replaced.

### Collateral Module
Collateralization of Filecoin nodes requires multiple steps to complete, and the Collateral Module manages the entire process.
- Add Collateral - Collateralizes the node to the asset package.
- Locking collateral - locks part of the node's assets.

### Liquidation Module
When a default condition occurs, the liquidation module will do the liquidation of the asset package, which includes two ways.
- Termination Node - Recover all assets through the Termination Node
- Debt Auction - recovering the assets by auction in case it is not possible to terminate the node.
Liquidation is based on two principles
- Maximizing coverage of the debt
- Maximizing the return to the collateral owner


### Governance Module
The Governance module contains, tokens and contracts for authorization, voting, proposal execution and voting security.

## Products

FilFi.app is a DApp with web interface, user login with their private wallet.

## Other issues

**Is it based on raw or adjusted power?**

The collateral assets are calculated based on the adjusted power.

**What if I sealed more sectors after collateral a node?**

Only the locked assets are counted as collateral assets, and this locked ratio can be 0%~100% freely allocated and adjusted at any time. After sealing more sections, the absolute value of locked assets will not change, and the ratio will be adjusted automatically due to the change of denominator. The   new power needs to be readjusted to the locked ratio before it can become a collateral asset. Unlocked assets do not participate in financial calculations, will not enter liquidation and are safe.

**How about Gas fees?**

Currently it is not possible to pledge worker wallets, so Gas fees are outside of the collateral assets and do not need to participate in the financial calculations. The collateralized party needs to ensure that there is sufficient FIL in the worker's wallet to cover future Gas fees.

**What about penalties by Filecoin network?**

Poor node maintenance is the cause of netwokr penalties, and the responsibility for node maintenance lies with the borrowers. Penalties due to the borrower's own reasons will be reflected in the change of the value of the asset package, and the continuous decrease of the asset value may trigger the liquidation mechanism. The protocal encourages borrowers to do a good job of node maintenance and prevent liquidation event to occur, so an additional penalty is added for the liquidation event to urge the borrowers to fulfill its responsibilities.



