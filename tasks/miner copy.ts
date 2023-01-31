import { task } from "hardhat/config"

// const contractJson = require("/Users/leo/Codebase/contracts/filfi/deployments/hyperspace/Filfi.json");
// const contractAddress = contractJson.address;
const fa = require("@glif/filecoin-address");
const util = require("util");
const request = util.promisify(require("request"));

async function callRpc(method: string, params: string) {
    var options = {
      method: "POST",
      // url: "https://wallaby.node.glif.io/rpc/v0",
      // url: "http://localhost:1234/rpc/v0",
      url: "https://api.hyperspace.node.glif.io/rpc/v1",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        jsonrpc: "2.0",
        method: method,
        params: params,
        id: 1,
      }),
    };
    const res = await request(options);
    return JSON.parse(res.body).result;
}

task("get-balance", "Calls the miner Contract to read the amount of balance")
  .addParam("contract", "The address the SimpleCoin contract")
  .setAction(async (taskArgs, { ethers }) => {
    const patchOwner = async function() {
      const [signer] = await ethers.getSigners();
    
      // for networks that absolutely require type 2 transactions, avoid
      // the hardhat signer by creating a wallet.
      console.log("==========", (await signer.getChainId()).toString())
      if ((await signer.getChainId()).toString().match(/31415/)) {
        // return new ethers.Wallet(process.env.PRIVATE_KEY, ethers.provider);
        return new ethers.Wallet("81483646f8d79b3a799144cafb9dc4eca58d17a6f198ba5cd3d5d27d1d24bb48", ethers.provider);
      }
    
      // for networks that are backwards compatible, allow
      // hardhat to do unenveloped transactions at the potential
      // of overpaying for gas
      return signer; 
    }
    
    const contractAddr = taskArgs.contract
    // const account = taskArgs.account
    // const networkId = network.name
    // console.log("Reading SimpleCoin owned by", account, " on network ", networkId)
    const Filfi = await ethers.getContractFactory("Loan")
    //Get signer information
    // const accounts = await ethers.getSigners()
    // const signer = accounts[0]
    console.log("--------------------2");
    const minerCoinContract = new ethers.Contract(contractAddr, Filfi.interface, new ethers.Wallet("81483646f8d79b3a799144cafb9dc4eca58d17a6f198ba5cd3d5d27d1d24bb48", ethers.provider))
    console.log("--------------------3");
    let result = await minerCoinContract.getAvailableBalance("t01823")
    // let result = await minerCoinContract.test("sdfs")
    console.log("--------------------4");
    console.log("Data is: ", result)
  })

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {}