import {
  createPublicClient,
  http,
  decodeFunctionResult
} from "viem";

const PLATFORM_ADDRESS =
  process.env.SOMNIA_AGENT_PLATFORM_ADDRESS ||
  "0x037Bb9C718F3f7fe5eCBDB0b600D607b52706776";

const RPC_URL =
  process.env.SOMNIA_RPC_URL ||
  "https://dream-rpc.somnia.network/";

const REQUEST_ID = process.env.REQUEST_ID;

const platformAbi = [
  {
    type: "function",
    name: "getRequest",
    inputs: [{ type: "uint256", name: "requestId" }],
    outputs: [
      {
        type: "tuple",
        components: [
          { type: "uint256", name: "id" },
          { type: "address", name: "requester" },
          { type: "address", name: "callbackAddress" },
          { type: "bytes4", name: "callbackSelector" },
          { type: "address[]", name: "subcommittee" },
          {
            type: "tuple[]",
            name: "responses",
            components: [
              { type: "address", name: "validator" },
              { type: "bytes", name: "result" },
              { type: "uint8", name: "status" },
              { type: "uint256", name: "receipt" },
              { type: "uint256", name: "timestamp" },
              { type: "uint256", name: "executionCost" }
            ]
          },
          { type: "uint256", name: "responseCount" },
          { type: "uint256", name: "failureCount" },
          { type: "uint256", name: "threshold" },
          { type: "uint256", name: "createdAt" },
          { type: "uint256", name: "deadline" },
          { type: "uint8", name: "status" },
          { type: "uint8", name: "consensusType" },
          { type: "uint256", name: "remainingBudget" },
          { type: "uint256", name: "perAgentBudget" }
        ]
      }
    ],
    stateMutability: "view"
  }
];

const agentMethodAbi = [
  {
    type: "function",
    name: "fetchString",
    inputs: [
      { type: "string", name: "url" },
      { type: "string", name: "selector" }
    ],
    outputs: [{ type: "string", name: "result" }]
  }
];

async function main() {
  if (!REQUEST_ID) {
    throw new Error("REQUEST_ID is missing");
  }

  const publicClient = createPublicClient({
    transport: http(RPC_URL)
  });

  console.log("Platform:", PLATFORM_ADDRESS);
  console.log("RPC:", RPC_URL);
  console.log("Request ID:", REQUEST_ID);

  const request = await publicClient.readContract({
    address: PLATFORM_ADDRESS,
    abi: platformAbi,
    functionName: "getRequest",
    args: [BigInt(REQUEST_ID)]
  });

  console.log("Status:", Number(request.status));
  console.log("Response count:", Number(request.responseCount));
  console.log("Responses length:", request.responses.length);

  if (!request.responses || request.responses.length === 0) {
    throw new Error("No responses returned");
  }

  const responseBytes = request.responses[0].result;

  const result = decodeFunctionResult({
    abi: agentMethodAbi,
    functionName: "fetchString",
    data: responseBytes
  });

  console.log("Result:", result);

  console.log(
    JSON.stringify({
      request_id: REQUEST_ID,
      status: Number(request.status),
      result
    })
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
