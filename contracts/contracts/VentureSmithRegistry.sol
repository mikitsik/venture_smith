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
    struct OpportunityPassport {
        address founder;
        bytes32 metadataHash;
        uint16 score;
        bytes32 resultHash;
    }

    IAgentRequester public immutable platform;

    address public owner;
    uint256 public llmAgentId;
    uint256 public nextPassportId = 1;

    uint256 public constant SUBCOMMITTEE_SIZE = 3;
    uint256 public constant LLM_PRICE_PER_AGENT = 0.07 ether;

    mapping(uint256 => OpportunityPassport) private passports;
    mapping(uint256 => uint256) public requestToPassportId;
    mapping(uint256 => bool) public pendingRequests;

    event OpportunityPassportCreated(
        uint256 indexed passportId,
        address indexed founder,
        bytes32 indexed metadataHash,
        string metadataURI
    );

    event OpportunityEvaluationRequested(
        uint256 indexed passportId,
        uint256 indexed requestId,
        uint256 indexed agentId
    );

    event OpportunityPassportEvaluated(
        uint256 indexed passportId,
        address indexed founder,
        uint16 score,
        bytes32 indexed resultHash
    );

    event OpportunityPassportFailed(
        uint256 indexed passportId,
        address indexed founder
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

    function createOpportunityPassport(
        bytes32 metadataHash,
        string calldata metadataURI
    ) external returns (uint256 passportId) {
        require(metadataHash != bytes32(0), "Empty metadata hash");
        require(bytes(metadataURI).length > 0, "Empty metadata URI");

        passportId = nextPassportId;
        nextPassportId += 1;

        passports[passportId] = OpportunityPassport({
            founder: msg.sender,
            metadataHash: metadataHash,
            score: 0,
            resultHash: bytes32(0)
        });

        emit OpportunityPassportCreated(
            passportId,
            msg.sender,
            metadataHash,
            metadataURI
        );
    }

    function requestOpportunityEvaluation(
        uint256 passportId,
        string calldata evaluationPrompt
    ) external payable returns (uint256 requestId) {
        OpportunityPassport storage passport = passports[passportId];

        require(passport.founder != address(0), "Passport not found");
        require(msg.sender == passport.founder, "Not founder");
        require(passport.resultHash == bytes32(0), "Already evaluated");
        require(llmAgentId != 0, "LLM agent not set");
        require(bytes(evaluationPrompt).length > 0, "Empty prompt");

        bytes memory payload = abi.encodeWithSelector(
            ILlmInferenceAgent.inferNumber.selector,
            evaluationPrompt,
            int256(0),
            int256(100)
        );

        uint256 deposit = requiredEvaluationDeposit();
        require(msg.value >= deposit, "Underfunded");

        requestId = platform.createRequest{value: deposit}(
            llmAgentId,
            address(this),
            this.handleResponse.selector,
            payload
        );

        requestToPassportId[requestId] = passportId;
        pendingRequests[requestId] = true;

        emit OpportunityEvaluationRequested(passportId, requestId, llmAgentId);
    }

    function requiredEvaluationDeposit() public view returns (uint256) {
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

        uint256 passportId = requestToPassportId[requestId];
        OpportunityPassport storage passport = passports[passportId];

        if (status == ResponseStatus.Success && responses.length > 0) {
            int256 rawScore = abi.decode(responses[0].result, (int256));

            if (rawScore < 0) rawScore = 0;
            if (rawScore > 100) rawScore = 100;

            uint16 score = uint16(uint256(rawScore));
            bytes32 resultHash = keccak256(responses[0].result);

            passport.score = score;
            passport.resultHash = resultHash;

            emit OpportunityPassportEvaluated(
                passportId,
                passport.founder,
                score,
                resultHash
            );
        } else {
            emit OpportunityPassportFailed(passportId, passport.founder);
        }
    }

    function getOpportunityPassport(
        uint256 passportId
    ) external view returns (OpportunityPassport memory) {
        require(passports[passportId].founder != address(0), "Passport not found");
        return passports[passportId];
    }

    receive() external payable {}
}
