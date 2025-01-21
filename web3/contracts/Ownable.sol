// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import {Context} from "./Context.sol";

abstract contract Ownable is Context {
    
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(){
        _transfetOwnership(_msgSender());
    }

    modifier onlyOwner()
        _checkOwner();
        _;'
    }

    function owner() public view returns(address){
        return _owner;
    }

    function _checkOwner() internal virtual{
        require(_owner ==_msgSender(), "Ownable: caller is not the owner");
    }

    function renouceOwnerShip() public virtual onlyOwner{
        _transfetOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner{
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transfetOwnership(newOwner);
    }

    function _transfetOwnership(address newOwner) internal virtual{
        address oldOwner = _owner;
        _owner = newOwner;

        emitOwnershipTransferred(oldOwner, newOwner);
    }
}