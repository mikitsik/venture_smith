const hre = require("hardhat");

const PLATFORM_ADDRESS =
  process.env.SOMNIA_AGENT_PLATFORM_ADDRESS ||
  "0x037Bb9C718F3f7fe5eCBDB0b600D607b52706776";

const LLM_AGENT_ID = process.env.SOMNIA_LLM_AGENT_ID || "0";

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying with:", deployer.address);
  console.log("Somnia Agent Platform:", PLATFORM_ADDRESS);
  console.log("LLM Agent ID:", LLM_AGENT_ID);

  const VentureSmithRegistry = await hre.ethers.getContractFactory(
    "VentureSmithRegistry"
  );

  const registry = await VentureSmithRegistry.deploy(
    PLATFORM_ADDRESS,
    LLM_AGENT_ID
  );

  await registry.waitForDeployment();

  const address = await registry.getAddress();

  console.log("VentureSmithRegistry deployed to:", address);
  console.log("Constructor args:");
  console.log("  platform:", PLATFORM_ADDRESS);
  console.log("  llmAgentId:", LLM_AGENT_ID);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
