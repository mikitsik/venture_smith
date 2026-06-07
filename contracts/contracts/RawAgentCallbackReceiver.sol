// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract RawAgentCallbackReceiver {
    address public owner;
    address public lastSender;
    uint256 public callbackCount;
    bytes public lastData;

    event CallbackCaptured(
        address indexed sender,
        uint256 indexed callbackCount,
        bytes data
    );

    constructor() {
        owner = msg.sender;
    }

    fallback() external payable {
        lastSender = msg.sender;
        callbackCount += 1;
        lastData = msg.data;

        emit CallbackCaptured(msg.sender, callbackCount, msg.data);
    }

    receive() external payable {}
}
