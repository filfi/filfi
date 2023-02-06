import { Address } from "@glif/filecoin-address";
import { StringDecoder } from "string_decoder";



const { expect } = require("chai");
const { ethers } = require("hardhat");
const util = require("util");
const request = util.promisify(require("request"));
const fa = require("@glif/filecoin-address")
const leb = require('leb128')
const base32Decode = require('base32-decode')




const ProtocolIndicator = {
  ID: 0,
  SECP256K1: 1,
  ACTOR: 2,
  BLS: 3,
  DELEGATED: 4,
}

// describe("Test ConfirmChangeBeneficiary contract", function() {
//   it("Deployment should assign  of tokens to the owner", async function() {
//     const [owner] = await ethers.getSigners();

//     const FilFi = await ethers.getContractFactory("ConfirmChangeBeneficiary");

//     const FilFiToken = await FilFi.deploy();
//     await FilFiToken.deployed();

//     console.log("FilFiToken address:", FilFiToken.address);

//     await FilFiToken.ConfirmChangeBen(stringToByte('1000'),1000, stringToByte("0x4247b30a4795c3F215274d2eE5666830E8f4f548"));
    
//   });
// });

// describe("Test ConfirmChangeBeneficiary contract", function() {
//     it("Deployment should assign  of tokens to the owner", async function() {

//         async function callRpc(method: string, params: any) {
//             var options = {
//               method: "POST",
//               // url: "https://wallaby.node.glif.io/rpc/v0",
//               url: "https://api.hyperspace.node.glif.io/rpc/v1",
//               headers: {
//                 "Content-Type": "application/json",
//               },
//               body: JSON.stringify({
//                 jsonrpc: "2.0",
//                 method: method,
//                 params: params,
//                 id: 1,
//               }),
//             };
//             const res = await request(options);
//             return JSON.parse(res.body).result;
//           }

//         const contractAddr = '0x234C117737AEcED606425ae16F2B927a212647a6'
//         const SimpleCoin = await ethers.getContractFactory("Pledge")
//         const priorityFee = await callRpc("eth_maxPriorityFeePerGas", [])

    
//         //Get signer information
//         const accounts = await ethers.getSigners()
//         const signer = accounts[0]
    
    
//         const simpleCoinContract = new ethers.Contract(contractAddr, SimpleCoin.interface, signer)
//         const result =  await simpleCoinContract.confirmChangeBeneficiary({
//             gasLimit: 1000000000,
//             maxPriorityFeePerGas: priorityFee
//           })
//         console.log("Data is: ", result)
//         console.log("Data is: ", result.data)
        
//     });
//   });

  describe(" contract get available_balance", function() {
    it("Deployment should assign  of tokens to the owner", async function() {



      function addressAsBytes(address: string): Buffer {
        let address_decoded, payload, checksum
        const protocolIndicator = address[1]
        const protocolIndicatorByte = `0${protocolIndicator}`
        switch (Number(protocolIndicator)) {
          case ProtocolIndicator.ID:
            return Buffer.concat([Buffer.from(protocolIndicatorByte, 'hex'), Buffer.from(leb.unsigned.encode(address.substr(2)))])
          case ProtocolIndicator.ACTOR:
            address_decoded = base32Decode(address.slice(2).toUpperCase(), 'RFC4648')
      
            payload = address_decoded.slice(0, -4)
            checksum = Buffer.from(address_decoded.slice(-4))
      
            if (payload.byteLength !== 20) {
            }
            break
          default:
          }
        
          const bytes_address = Buffer.concat([Buffer.from(protocolIndicatorByte, 'hex'), Buffer.from(payload)])
        
          return bytes_address
      
        }
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

        const contractAddr = '0x3e3B63545fa9E375467E479F0AF1b2D72a2113a4'
        const SimpleCoin = await ethers.getContractFactory("Pledge")
        const priorityFee = await callRpc("eth_maxPriorityFeePerGas", [])
        var actor_id = addressAsBytes('t01129')

        console.log("actor_id is: ", actor_id.toString())
        

    
        //Get signer information
        const accounts = await ethers.getSigners()
        const signer = accounts[0]
    
    
        const simpleCoinContract = new ethers.Contract(contractAddr, SimpleCoin.interface, signer)
        const result =  await simpleCoinContract.get_available_balance(actor_id,{
            gasLimit: 1000000000,
            maxPriorityFeePerGas: priorityFee
          })
        console.log("Data is: ", result)
        console.log("Data is: ", result.data)
        
    });
  });


  // describe(" contract get_beneficiary", function() {
  //   it("Deployment should assign  of tokens to the owner", async function() {

  //       async function callRpc(method: string, params: any) {
  //           var options = {
  //             method: "POST",
  //             // url: "https://wallaby.node.glif.io/rpc/v0",
  //             url: "https://api.hyperspace.node.glif.io/rpc/v1",
  //             headers: {
  //               "Content-Type": "application/json",
  //             },
  //             body: JSON.stringify({
  //               jsonrpc: "2.0",
  //               method: method,
  //               params: params,
  //               id: 1,
  //             }),
  //           };
  //           const res = await request(options);
  //           return JSON.parse(res.body).result;
  //         }

  //       const contractAddr = '0x36Fd361bCa909DE5c6c9A5dD87D87a721351CA5A'
  //       const SimpleCoin = await ethers.getContractFactory("Pledge")
  //       const priorityFee = await callRpc("eth_maxPriorityFeePerGas", [])

  //       var actor_id = 0x000469

  //       //Get signer information
  //       const accounts = await ethers.getSigners()
  //       const signer = accounts[0]
    
    
  //       const simpleCoinContract = new ethers.Contract(contractAddr, SimpleCoin.interface, signer)
  //       const result =  await simpleCoinContract.get_beneficiary(actor_id,{
  //           gasLimit: 1000000000,
  //           maxPriorityFeePerGas: priorityFee
  //         })
  //       console.log("Data is: ", result)
  //       console.log("Data is: ", result.data)
        
  //   });
  // });