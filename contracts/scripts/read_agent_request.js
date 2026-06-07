const hre = require("hardhat");

const PLATFORM_ADDRESS =
  process.env.SOMNIA_AGENT_PLATFORM_ADDRESS ||
  "0x037Bb9C718F3f7fe5eCBDB0b600D607b52706776";

const REQUEST_ID = process.env.REQUEST_ID;
const FROM_BLOCK = process.env.FROM_BLOCK;
const TO_BLOCK = process.env.TO_BLOCK;

const platformAbi = [
  "event RequestCreated(uint256 indexed requestId,uint256 indexed agentId,uint256 perAgentBudget,bytes payload,address[] subcommittee)",
  "event RequestFinalized(uint256 indexed requestId,uint8 status)"
];

async function main() {
  if (!REQUEST_ID) throw new Error("REQUEST_ID is missing");
  if (!FROM_BLOCK) throw new Error("FROM_BLOCK is missing");
  if (!TO_BLOCK) throw new Error("TO_BLOCK is missing");

  const iface = new hre.ethers.Interface(platformAbi);

  const fromBlock = Number(FROM_BLOCK);
  const toBlock = Number(TO_BLOCK);

  console.log("Platform:", PLATFORM_ADDRESS);
  console.log("Request ID:", REQUEST_ID);
  console.log("From block:", fromBlock);
  console.log("To block:", toBlock);

  const createdLogs = await getLogsByEvent({
    eventSignature: "RequestCreated(uint256,uint256,uint256,bytes,address[])",
    requestId: REQUEST_ID,
    fromBlock,
    toBlock
  });

  const finalizedLogs = await getLogsByEvent({
    eventSignature: "RequestFinalized(uint256,uint8)",
    requestId: REQUEST_ID,
    fromBlock,
    toBlock
  });

  console.log("RequestCreated events:", createdLogs.length);
  console.log("RequestFinalized events:", finalizedLogs.length);

  for (const log of createdLogs) {
    const parsed = iface.parseLog({
      topics: log.topics,
      data: log.data
    });

    console.log("Created TX:", log.transactionHash);
    console.log("Created block:", Number(log.blockNumber));
    console.log("Agent ID:", parsed.args.agentId.toString());
    console.log("Per-agent budget:", parsed.args.perAgentBudget.toString());
  }

  for (const log of finalizedLogs) {
    const parsed = iface.parseLog({
      topics: log.topics,
      data: log.data
    });

    console.log("Finalized TX:", log.transactionHash);
    console.log("Finalized block:", Number(log.blockNumber));
    console.log("Status:", parsed.args.status.toString());
  }

  if (finalizedLogs.length === 0) {
    console.log("No finalization event in this block range.");
  }
}

async function getLogsByEvent({ eventSignature, requestId, fromBlock, toBlock }) {
  const topic0 = hre.ethers.id(eventSignature);
  const topic1 = hre.ethers.zeroPadValue(hre.ethers.toBeHex(requestId), 32);

  return hre.network.provider.send("eth_getLogs", [
    {
      address: PLATFORM_ADDRESS,
      fromBlock: hre.ethers.toQuantity(fromBlock),
      toBlock: hre.ethers.toQuantity(toBlock),
      topics: [topic0, topic1]
    }
  ]);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
