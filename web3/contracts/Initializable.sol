// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.29;

//IMPORTING
import {Address} from "./Address.sol";


abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
           (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
              "Initializable: contract is already initialized" 
        );

        _initialized= 1;
        if(isTopLevelCall){
            _initializing = true;
        }

        _;

        if(isTopLevelcall){
            _initializing = false;
            emit Initialized(_initialized);
        }
    }


    modifier reinitializer(uint8 version){
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;

        _;

        _initializing = false;
        emit Initialized(version);
    }


    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing")
        if(_initialized < type(uint8).max){
            _initialized = type(uint8).max;

            emit Initialized(type(uint8).max);
        }
    }


}