require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config()

const PRIVATE_KEY = process.env.PRIVATEKEY;


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    moonbase: {
      url: process.env.RPC,
      accounts: [PRIVATE_KEY]
    },
  },  
};
