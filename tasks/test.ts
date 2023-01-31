import { task } from "hardhat/config"

const fa = require("@glif/filecoin-address");
const util = require("util");
const request = util.promisify(require("request"));

task("transfer", "")
  .addParam("contract", "")
  .setAction(async (taskArgs, {network, ethers}) => {
    const contractAddr = taskArgs.contract
    const networkId = network.name
    
    async function callRpc(method: string, params: any) {
      var options = {
        method: "POST",
        // url: "https://wallaby.node.glif.io/rpc/v0",
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

    const priorityFee = await callRpc("eth_maxPriorityFeePerGas", [])


    console.log("Calling Protocol method")
    const Protocol = await ethers.getContractFactory("Protocol")
    //Get signer information
    const accounts = await ethers.getSigners()
    const signer = accounts[0]
    console.log(contractAddr)
    const protocolContract = new ethers.Contract(contractAddr, Protocol.interface, signer)
    console.log("0000000000")
    await protocolContract.deposit({
        gasLimit: 1000000000,
        maxPriorityFeePerGas: priorityFee
      })
    // let result = await protocolContract.deposit({
    //     gasLimit: 1000000000,
    //     maxPriorityFeePerGas: priorityFee
    //   })
    // console.log("owner balance:", result)

  })


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {}