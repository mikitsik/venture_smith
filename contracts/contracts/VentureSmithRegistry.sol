// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    IAgentRequester,
    IAgentRequesterHandler,
    Response,
    Request,
    ResponseStatus
} from "./interfaces/IAgentRequester.sol";

interface ILlmInferenceAgent {
    function inferNumber(
        string calldata prompt,
        int256 min,
        int256 max
    ) external returns (int256);
}

contract VentureSmithRegistry is IAgentRequesterHandler {
    enum Status {
        Requested,
        AgentRequested,
        Completed,
        Failed
    }

    struct ScoutRun {
        address founder;
        bytes32 profileHash;
        string goal;
        string metadataURI;
        Status status;
        uint16 score;
        bytes32 resultHash;
        uint256 agentRequestId;
        uint256 createdAt;
        uint256 completedAt;
    }

    IAgentRequester public immutable platform;

    address public owner;
    uint256 public llmAgentId;
    uint256 public nextRunId = 1;

    uint256 public constant SUBCOMMITTEE_SIZE = 3;
    uint256 public constant LLM_PRICE_PER_AGENT = 0.07 ether;

    mapping(uint256 => ScoutRun) private scoutRuns;
    mapping(uint256 => uint256) public requestToRunId;
    mapping(uint256 => bool) public pendingRequests;

    event ScoutRunCreated(
        uint256 indexed runId,
        address indexed founder,
        bytes32 indexed profileHash,
        string goal,
        string metadataURI
    );

    event ScoutAgentRequested(
        uint256 indexed runId,
        uint256 indexed requestId,
        uint256 indexed agentId
    );

    event ScoutRunCompleted(
        uint256 indexed runId,
        address indexed founder,
        uint16 score,
        bytes32 indexed resultHash
    );

    event ScoutRunFailed(
        uint256 indexed runId,
        address indexed founder,
        bytes32 indexed resultHash
    );

    event LlmAgentUpdated(uint256 indexed oldAgentId, uint256 indexed newAgentId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address platform_, uint256 llmAgentId_) {
        require(platform_ != address(0), "Zero platform");

        owner = msg.sender;
        platform = IAgentRequester(platform_);
        llmAgentId = llmAgentId_;
    }

    function setLlmAgentId(uint256 newLlmAgentId) external onlyOwner {
        uint256 oldAgentId = llmAgentId;
        llmAgentId = newLlmAgentId;

        emit LlmAgentUpdated(oldAgentId, newLlmAgentId);
    }

    function createScoutRun(
        bytes32 profileHash,
        string calldata goal,
        string calldata metadataURI
    ) external returns (uint256 runId) {
        require(bytes(goal).length > 0, "Empty goal");

        runId = nextRunId;
        nextRunId += 1;

        scoutRuns[runId] = ScoutRun({
            founder: msg.sender,
            profileHash: profileHash,
            goal: goal,
            metadataURI: metadataURI,
            status: Status.Requested,
            score: 0,
            resultHash: bytes32(0),
            agentRequestId: 0,
            createdAt: block.timestamp,
            completedAt: 0
        });

        emit ScoutRunCreated(runId, msg.sender, profileHash, goal, metadataURI);
    }

    function requestScoutScore(uint256 runId) external payable returns (uint256 requestId) {
        ScoutRun storage run = scoutRuns[runId];

        require(run.founder != address(0), "Run not found");
        require(run.status == Status.Requested, "Run not requestable");
        require(msg.sender == run.founder, "Not founder");
        require(llmAgentId != 0, "LLM agent not set");

        string memory prompt = string.concat(
            "You are scoring a startup opportunity for a solo Ruby on Rails founder. ",
            "Return only one integer from 0 to 100. ",
            "Score founder fit, market pain, MVP feasibility, and 30-day build potential. ",
            "Goal: ",
            run.goal
        );

        bytes memory payload = abi.encodeWithSelector(
            ILlmInferenceAgent.inferNumber.selector,
            prompt,
            int256(0),
            int256(100)
        );

        uint256 deposit = requiredScoutScoreDeposit();
        require(msg.value >= deposit, "Underfunded");

        requestId = platform.createRequest{value: deposit}(
            llmAgentId,
            address(this),
            this.handleResponse.selector,
            payload
        );

        run.status = Status.AgentRequested;
        run.agentRequestId = requestId;

        requestToRunId[requestId] = runId;
        pendingRequests[requestId] = true;

        emit ScoutAgentRequested(runId, requestId, llmAgentId);
    }

    function requiredScoutScoreDeposit() public view returns (uint256) {
        return platform.getRequestDeposit() + (LLM_PRICE_PER_AGENT * SUBCOMMITTEE_SIZE);
    }

    function handleResponse(
        uint256 requestId,
        Response[] memory responses,
        ResponseStatus status,
        Request memory
    ) external override {
        require(msg.sender == address(platform), "Only platform");
        require(pendingRequests[requestId], "Unknown request");

        pendingRequests[requestId] = false;

        uint256 runId = requestToRunId[requestId];
        ScoutRun storage run = scoutRuns[runId];

        if (status == ResponseStatus.Success && responses.length > 0) {
            int256 rawScore = abi.decode(responses[0].result, (int256));

            if (rawScore < 0) {
                rawScore = 0;
            }

            if (rawScore > 100) {
                rawScore = 100;
            }

            uint16 score = uint16(uint256(rawScore));

            run.status = Status.Completed;
            run.score = score;
            run.resultHash = keccak256(responses[0].result);
            run.completedAt = block.timestamp;

            emit ScoutRunCompleted(runId, run.founder, score, run.resultHash);
        } else {
            run.status = Status.Failed;
            run.resultHash = bytes32(0);
            run.completedAt = block.timestamp;

            emit ScoutRunFailed(runId, run.founder, bytes32(0));
        }
    }

    function getScoutRun(uint256 runId) external view returns (ScoutRun memory) {
        require(scoutRuns[runId].founder != address(0), "Run not found");
        return scoutRuns[runId];
    }

    receive() external payable {}
}
