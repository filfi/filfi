const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Test Filfi contract", function() {
  it("Deployment should assign  of tokens to the owner", async function() {
    const [owner] = await ethers.getSigners();

    const FilFi = await ethers.getContractFactory("Filfi");

    const FilFiToken = await FilFi.deploy();
    await FilFiToken.deployed();

    await FilFiToken.supply(200000000000000);

    const FilFiSupplyBalance = await FilFiToken.TotalSupply();
    console.log("FilFiSupplyBalance: ", FilFiSupplyBalance.toString());

    const ownerSupplyBalance = await FilFiToken.supplyBalanceOf(owner.address);
    console.log("owner supplyBalanceOf: %d", ownerSupplyBalance);

    setTimeout(function(){
      //doSomething
    }, 3000);

    // expect(await FilFiToken.supplyBalanceOf(owner.address)).to.equal(200000000000000);

    // await FilFiToken.withdraw(100000000000000);
    // var supplyBalance = await FilFiToken.supplyBalanceOf(owner.address);
    // console.log("owner supplyBalance: %d", supplyBalance);

    var interest = await FilFiToken.totalSupplyInterestOf(owner.address);
    console.log("owner totalSupplyInterestOf: %d", interest);
    
  });
});

