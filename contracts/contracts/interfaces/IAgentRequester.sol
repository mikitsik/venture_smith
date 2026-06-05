// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

enum ResponseStatus {
    Success,
    Failed,
    TimedOut
}

struct Response {
    bytes result;
    address responder;
}

struct Request {
    address requester;
    address callbackAddress;
    bytes4 callbackSelector;
    uint256 agentId;
    bytes payload;
}

interface IAgentRequester {
    function getRequestDeposit() external view returns (uint256);

    function createRequest(
        uint256 agentId,
        address callbackAddress,
        bytes4 callbackSelector,
        bytes calldata payload
    ) external payable returns (uint256 requestId);
}

interface IAgentRequesterHandler {
    function handleResponse(
        uint256 requestId,
        Response[] memory responses,
        ResponseStatus status,
        Request memory request
    ) external;
}
