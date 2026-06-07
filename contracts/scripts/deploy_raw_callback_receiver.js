const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying with:", deployer.address);

  const Receiver = await hre.ethers.getContractFactory(
    "RawAgentCallbackReceiver"
  );

  const receiver = await Receiver.deploy();
  await receiver.waitForDeployment();

  const address = await receiver.getAddress();

  console.log("RawAgentCallbackReceiver deployed to:", address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
