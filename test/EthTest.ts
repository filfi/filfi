const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Token contract", function() {
  it("Deployment should assign the total supply of tokens to the owner", async function() {
    const [owner] = await ethers.getSigners();

    console.log("owner address: ", await owner.getAddress());
    console.log("owner balance: ", (await owner.getBalance()).toString()); 
    
  });
});

