const hre = require("hardhat");

const PLATFORM_ADDRESS =
  process.env.SOMNIA_AGENT_PLATFORM_ADDRESS ||
  "0x037Bb9C718F3f7fe5eCBDB0b600D607b52706776";

const JSON_API_AGENT_ID = "13174292974160097713";

const GITHUB_URL =
  process.env.GITHUB_TEST_URL ||
  "https://api.github.com/users/mikitsik";

const JSON_SELECTOR =
  process.env.JSON_SELECTOR ||
  "login";

const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
const ZERO_SELECTOR = "0x00000000";

const CALLBACK_ADDRESS = process.env.CALLBACK_ADDRESS || ZERO_ADDRESS;
const CALLBACK_SELECTOR = process.env.CALLBACK_SELECTOR || ZERO_SELECTOR;

const PER_AGENT_EXECUTION_COST = 30_000_000_000_000_000n; // 0.03 STT
const SUBCOMMITTEE_SIZE = 3n;

const platformAbi = [
  "function getRequestDeposit() view returns (uint256)",
  "function createRequest(uint256 agentId,address callbackAddress,bytes4 callbackSelector,bytes payload) payable returns (uint256 requestId)",
  "event RequestCreated(uint256 indexed requestId,uint256 indexed agentId,uint256 perAgentBudget,bytes payload,address[] subcommittee)"
];

const receiverAbi = [
  "function callbackCount() view returns (uint256)",
  "function lastSender() view returns (address)",
  "function lastData() view returns (bytes)"
];

const agentAbi = [
  "function fetchString(string url,string selector) returns (string result)"
];

async function main() {
  const [signer] = await hre.ethers.getSigners();

  const platform = new hre.ethers.Contract(
    PLATFORM_ADDRESS,
    platformAbi,
    signer
  );

  const agentInterface = new hre.ethers.Interface(agentAbi);

  const payload = agentInterface.encodeFunctionData("fetchString", [
    GITHUB_URL,
    JSON_SELECTOR
  ]);

  const reserve = await platform.getRequestDeposit();
  const reward = PER_AGENT_EXECUTION_COST * SUBCOMMITTEE_SIZE;
  const deposit = reserve + reward;

  const receiver = callbackEnabled()
    ? new hre.ethers.Contract(CALLBACK_ADDRESS, receiverAbi, signer)
    : null;

  const callbackCountBefore = receiver
    ? await receiver.callbackCount()
    : 0n;

  console.log("Wallet:", signer.address);
  console.log("Platform:", PLATFORM_ADDRESS);
  console.log("Agent ID:", JSON_API_AGENT_ID);
  console.log("URL:", GITHUB_URL);
  console.log("Selector:", JSON_SELECTOR);
  console.log("Callback address:", CALLBACK_ADDRESS);
  console.log("Callback selector:", CALLBACK_SELECTOR);
  console.log("Callback count before:", callbackCountBefore.toString());
  console.log("Deposit wei:", deposit.toString());

  const expectedRequestId = await platform.createRequest.staticCall(
    JSON_API_AGENT_ID,
    CALLBACK_ADDRESS,
    CALLBACK_SELECTOR,
    payload,
    { value: deposit }
  );

  const tx = await platform.createRequest(
    JSON_API_AGENT_ID,
    CALLBACK_ADDRESS,
    CALLBACK_SELECTOR,
    payload,
    { value: deposit }
  );

  console.log("TX:", tx.hash);

  const receipt = await tx.wait();
  const requestId = extractRequestId(platform, receipt) || expectedRequestId;

  console.log("Request ID:", requestId.toString());
  console.log("Created block:", receipt.blockNumber);

  if (!receiver) {
    console.log("No callback receiver configured.");
    return;
  }

  const callback = await waitForCallback(receiver, callbackCountBefore);

  console.log("Callback count after:", callback.callbackCount.toString());
  console.log("Last sender:", callback.lastSender);
  console.log("Last data:", callback.lastData);

  console.log(JSON.stringify({
    tx_hash: tx.hash,
    request_id: requestId.toString(),
    callback_count: callback.callbackCount.toString(),
    callback_sender: callback.lastSender,
    callback_data: callback.lastData
  }));
}

function callbackEnabled() {
  return CALLBACK_ADDRESS !== ZERO_ADDRESS;
}

function extractRequestId(platform, receipt) {
  for (const log of receipt.logs) {
    try {
      const parsed = platform.interface.parseLog(log);

      if (parsed && parsed.name === "RequestCreated") {
        return parsed.args.requestId;
      }
    } catch (_error) {
      // Skip unrelated logs.
    }
  }

  return null;
}

async function waitForCallback(receiver, callbackCountBefore) {
  const maxAttempts = 90;
  const delayMs = 5_000;

  for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
    const callbackCount = await receiver.callbackCount();

    console.log(
      `Waiting callback: count=${callbackCount}, attempt=${attempt}`
    );

    if (callbackCount > callbackCountBefore) {
      return {
        callbackCount,
        lastSender: await receiver.lastSender(),
        lastData: await receiver.lastData()
      };
    }

    await sleep(delayMs);
  }

  throw new Error("Timed out waiting for callback");
}

function sleep(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
