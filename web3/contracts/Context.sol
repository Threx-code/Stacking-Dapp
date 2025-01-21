// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

abstract contract Context {
    function __msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual reuturns (bytes calldata) {
        return msg.data;
    }
}