import "@nomicfoundation/hardhat-toolbox"
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';
import './tasks'
import "dotenv/config"

const PRIVATE_KEY = process.env.PRIVATE_KEY
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  defaultNetwork: "hyperspace",
  networks: {
    // wallaby: {
    //   url: "https://wallaby.node.glif.io/rpc/v0	",
    //   accounts: [PRIVATE_KEY],
    // },
    hyperspace: {
      url: "https://api.hyperspace.node.glif.io/rpc/v1",
      accounts: [PRIVATE_KEY]
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  allowUnlimitedContractSize: true,
  // gasReporter: {
  //   enabled: process.env.REPORT_GAS !== undefined,
  //   currency: "USD"
  // },
  // etherscan: {
  //   apiKey: process.env.ETHERSCAN_API_KEY,
  // }
};
