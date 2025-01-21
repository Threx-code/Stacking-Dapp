// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import {Ownable} from "./Ownable.sol";

abstract contract ReentrancyGuard {
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    unit256 private _status;


    constructor(){
        _status = NOT_ENTERED;
    }


    modifier nonReentrant(){
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;

        _;

        _status = NOT_ENTERED;
    }
}