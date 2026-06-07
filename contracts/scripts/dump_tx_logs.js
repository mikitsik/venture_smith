const hre = require("hardhat");

const TX_HASH = process.env.TX_HASH;

async function main() {
  if (!TX_HASH) {
    throw new Error("TX_HASH is missing");
  }

  const receipt = await hre.ethers.provider.getTransactionReceipt(TX_HASH);

  console.log("TX:", TX_HASH);
  console.log("Block:", receipt.blockNumber);
  console.log("Logs:", receipt.logs.length);

  receipt.logs.forEach((log, index) => {
    console.log("\n--- LOG", index, "---");
    console.log("address:", log.address);
    console.log("topics:", log.topics);
    console.log("data:", log.data);
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
