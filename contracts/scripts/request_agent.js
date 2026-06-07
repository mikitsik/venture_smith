const hre = require("hardhat");

const PLATFORM_ADDRESS = process.env.SOMNIA_AGENT_PLATFORM_ADDRESS;
const AGENT_ID = process.env.AGENT_ID;
const CALLBACK_ADDRESS = process.env.CALLBACK_ADDRESS;
const CALLBACK_SELECTOR = process.env.CALLBACK_SELECTOR;

const AGENT_FUNCTION_SIGNATURE = process.env.AGENT_FUNCTION_SIGNATURE;
const AGENT_ARGS_JSON = process.env.AGENT_ARGS_JSON;
const RAW_PAYLOAD = process.env.RAW_PAYLOAD;
const REQUEST_VALUE_WEI = process.env.REQUEST_VALUE_WEI;

async function main() {
  validateEnv();

  const [signer] = await hre.ethers.getSigners();

  const platform = new hre.ethers.Contract(
    PLATFORM_ADDRESS,
    [
      "function getRequestDeposit() view returns (uint256)",
      "function createRequest(uint256 agentId,address callbackAddress,bytes4 callbackSelector,bytes payload) payable returns (uint256 requestId)"
    ],
    signer
  );

  const payload = buildPayload();
  const value = REQUEST_VALUE_WEI
    ? BigInt(REQUEST_VALUE_WEI)
    : await platform.getRequestDeposit();

  const requestId = await platform.createRequest.staticCall(
    AGENT_ID,
    CALLBACK_ADDRESS,
    CALLBACK_SELECTOR,
    payload,
    { value }
  );

  const tx = await platform.createRequest(
    AGENT_ID,
    CALLBACK_ADDRESS,
    CALLBACK_SELECTOR,
    payload,
    { value }
  );

  await tx.wait();

  console.log(JSON.stringify({
    tx_hash: tx.hash,
    request_id: requestId.toString(),
    agent_id: AGENT_ID,
    callback_address: CALLBACK_ADDRESS,
    callback_selector: CALLBACK_SELECTOR,
    value_wei: value.toString()
  }));
}

function buildPayload() {
  if (RAW_PAYLOAD) {
    return RAW_PAYLOAD;
  }

  if (!AGENT_FUNCTION_SIGNATURE || !AGENT_ARGS_JSON) {
    throw new Error(
      "Either RAW_PAYLOAD or AGENT_FUNCTION_SIGNATURE + AGENT_ARGS_JSON are required"
    );
  }

  const iface = new hre.ethers.Interface([AGENT_FUNCTION_SIGNATURE]);
  const functionName = AGENT_FUNCTION_SIGNATURE.match(/function\s+([^(]+)/)[1];
  const args = JSON.parse(AGENT_ARGS_JSON);

  return iface.encodeFunctionData(functionName, args);
}

function validateEnv() {
  const required = {
    SOMNIA_AGENT_PLATFORM_ADDRESS: PLATFORM_ADDRESS,
    AGENT_ID,
    CALLBACK_ADDRESS,
    CALLBACK_SELECTOR
  };

  Object.entries(required).forEach(([name, value]) => {
    if (!value) {
      throw new Error(`${name} is missing`);
    }
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
