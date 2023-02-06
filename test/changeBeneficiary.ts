import { StringDecoder } from "string_decoder";

const { expect } = require("chai");
const { ethers } = require("hardhat");
const util = require("util");
const request = util.promisify(require("request"));



function stringToByte(str) {
    var bytes = new Array();
    var len, c;
    len = str.length;
    for (var i = 0; i < len; i++) {
        c = str.charCodeAt(i);
        if (c >= 0x010000 && c <= 0x10FFFF) {
            bytes.push(((c >> 18) & 0x07) | 0xF0);
            bytes.push(((c >> 12) & 0x3F) | 0x80);
            bytes.push(((c >> 6) & 0x3F) | 0x80);
            bytes.push((c & 0x3F) | 0x80);
        } else if (c >= 0x000800 && c <= 0x00FFFF) {
            bytes.push(((c >> 12) & 0x0F) | 0xE0);
            bytes.push(((c >> 6) & 0x3F) | 0x80);
            bytes.push((c & 0x3F) | 0x80);
        } else if (c >= 0x000080 && c <= 0x0007FF) {
            bytes.push(((c >> 6) & 0x1F) | 0xC0);
            bytes.push((c & 0x3F) | 0x80);
        } else {
            bytes.push(c & 0xFF);
        }
    }
    return bytes;
}


function stringToBytes02  ( str ) {  

  var ch, st, re = []; 
  for (var i = 0; i < str.length; i++ ) { 
      ch = str.charCodeAt(i);  // get char  
      st = [];                 // set up "stack"  

     do {  
          st.push( ch & 0xFF );  // push byte to stack  
          ch = ch >> 8;          // shift value down by 1 byte  
      }    

      while ( ch );  
      // add stack contents to result  
      // done because chars have "wrong" endianness  
      re = re.concat( st.reverse() ); 
  }  
  // return an array of bytes  
  return re;  
} 


function stringToHex(str){

　　　　var val="";

　　　　for(var i = 0; i < str.length; i++){

　　　　　　if(val == "")

　　　　　　　　val = str.charCodeAt(i).toString(16);

　　　　　　else

　　　　　　　　val += "," + str.charCodeAt(i).toString(16);

　　　　}

　　　　return val;

}


function encodeUtf8(text) {
  const code = encodeURIComponent(text);
  const bytes = [];
  for (var i = 0; i < code.length; i++) {
      const c = code.charAt(i);
      if (c === '%') {
          const hex = code.charAt(i + 1) + code.charAt(i + 2);
          const hexVal = parseInt(hex, 16);
          bytes.push(hexVal);
          i += 2;
      } else bytes.push(c.charCodeAt(0));
  }
  return bytes;
}

function bytesToHex(bytes) {
  for (var hex = [], i = 0; i < bytes.length; i++) {
      hex.push((bytes[i] >>> 4).toString(16));
      hex.push((bytes[i] & 0xF).toString(16));
  }
  return hex.join("");
}

// Convert a hex string to a ASCII string
function hexToString(hexStr) {
  var hex = hexStr.toString();//force conversion
  var str = '';
  for (var i = 0; i < hex.length; i += 2)
      str += String.fromCharCode(parseInt(hex.substr(i, 2), 16));
  return str;
}


function bytesToString(bytes){
	return hexToString(bytesToHex(bytes));
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

        const contractAddr = '0x5a54EDAAFe17C9E89D83B49d265301f00873732a'
        const SimpleCoin = await ethers.getContractFactory("Pledge")
        const priorityFee = await callRpc("eth_maxPriorityFeePerGas", [])
        var actor_id = 0x000469
        

    
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


  describe(" contract get_beneficiary", function() {
    it("Deployment should assign  of tokens to the owner", async function() {

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

        const contractAddr = '0x5a54EDAAFe17C9E89D83B49d265301f00873732a'
        const SimpleCoin = await ethers.getContractFactory("Pledge")
        const priorityFee = await callRpc("eth_maxPriorityFeePerGas", [])

        var actor_id = 469

        //Get signer information
        const accounts = await ethers.getSigners()
        const signer = accounts[0]
    
    
        const simpleCoinContract = new ethers.Contract(contractAddr, SimpleCoin.interface, signer)
        const result =  await simpleCoinContract.get_beneficiary(actor_id,{
            gasLimit: 1000000000,
            maxPriorityFeePerGas: priorityFee
          })
        console.log("Data is: ", result)
        console.log("Data is: ", result.data)
        
    });
  });