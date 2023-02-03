import { task } from "hardhat/config"

const fa = require("@glif/filecoin-address");
const util = require("util");
const request = util.promisify(require("request"));

task("get-owner", "")
  .addParam("contractaddress", "")
  // .addParam("minerid", "t01064")
  .setAction(async (taskArgs, {network, ethers}) => {
    const contractAddr = taskArgs.contractaddress
    const {minerid} = taskArgs
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


    console.log("Calling getOwner method")
    const SimpleCoin = await ethers.getContractFactory("Loan")
    //Get signer information
    const accounts = await ethers.getSigners()
    const signer = accounts[0]

    const simpleCoinContract = new ethers.Contract(contractAddr, SimpleCoin.interface, signer)
    console.log(simpleCoinContract)
    let result = await simpleCoinContract.getOwner( {
        gasLimit: 1000000000,
        maxPriorityFeePerGas: priorityFee,
        // value: ethers.utils.parseEther("0.1"),
      })
    console.log("owner balance:", result)
  })


task("change-beneficiary", "")
  .addParam("contractaddress", "")
  // .addParam("minerid", "t01064")
  .setAction(async (taskArgs, {network, ethers}) => {
    const contractAddr = taskArgs.contractaddress
    const {minerid} = taskArgs
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


    console.log("Calling changeBeneficiary method")
    //Get signer information
    const accounts = await ethers.getSigners()
    const signer = accounts[0]

    const SimpleCoin = await ethers.getContractFactory("Loan")
    const simpleCoinContract = new ethers.Contract(contractAddr, SimpleCoin.interface, signer)
    let utf8Encode = new TextEncoder();
    
    let result = await simpleCoinContract.getOwner(utf8Encode.encode("t01129"), {
        gasLimit: 1000000000,
        maxPriorityFeePerGas: priorityFee
      })
    console.log("changeBeneficiary result:", result)

  })
  
// task("get-balance", "Calls the miner Contract to read the amount of balance")
//   .addParam("contract", "The address the SimpleCoin contract")
//   .setAction(async (taskArgs, {network, ethers }) => {
//     const priorityFee = await callRpc("eth_maxPriorityFeePerGas", null)
//     async function callRpc(method: string, params: any) {
//       var options = {
//         method: "POST",
//         // url: "https://wallaby.node.glif.io/rpc/v0",
//         url: "https://api.hyperspace.node.glif.io/rpc/v1",
//         headers: {
//           "Content-Type": "application/json",
//         },
//         body: JSON.stringify({
//           jsonrpc: "2.0",
//           method: method,
//           params: params,
//           id: 1,
//         }),
//       };
//       const res = await request(options);
//       return JSON.parse(res.body).result;
//     }
    
//     const contractAddr = taskArgs.contract
//     const Loan = await ethers.getContractFactory("Loan")
//     console.log(network.name)
//     const accounts = await ethers.getSigners()
//     const signer = accounts[0]
//     // new ethers.Wallet("81483646f8d79b3a799144cafb9dc4eca58d17a6f198ba5cd3d5d27d1d24bb48", ethers.provider)
//     const minerCoinContract = new ethers.Contract(contractAddr, Loan.interface, signer)
//     // let result = await minerCoinContract.getAvailableBalance({
//     //   gasLimit: 1000000000,
//     //   maxPriorityFeePerGas: priorityFee
//     // })
//     let result = await minerCoinContract.getOwner({
//       gasLimit: 1000000000,
//       maxPriorityFeePerGas: priorityFee
//     })
//     console.log("Data is: ", result)
//   })

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {}