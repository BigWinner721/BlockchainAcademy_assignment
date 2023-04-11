require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");
const dotenv = require("dotenv");
dotenv.config();

PRIVATE_KEY = process.env.PRKEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.18",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    tbsc: {
      url: `https://bsc-testnet.public.blastapi.io`,
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: process.env.SCANKEY, //bsc
  },
};
