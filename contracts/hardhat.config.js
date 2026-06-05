require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const accounts = process.env.PRIVATE_KEY
  ? [process.env.PRIVATE_KEY]
  : process.env.MNEMONIC
    ? { mnemonic: process.env.MNEMONIC }
    : [];

module.exports = {
  solidity: "0.8.24",
  networks: {
    somniaShannon: {
      url: process.env.SOMNIA_RPC_URL || "https://api.infra.testnet.somnia.network/",
      chainId: 50312,
      accounts,
    },
  },
};
