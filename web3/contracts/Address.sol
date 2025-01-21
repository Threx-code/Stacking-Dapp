// SPDX-License-Identifier: MIP

pragma solidity ^0.8.9;

library Address {


    // Purpose: 
    // Checks whether a given address is a smart contract.
    //
    // How it works: 
    // Uses the EXTCODESIZE opcode to check the size of the code stored at the account address. 
    // If the size is greater than 0, the address belongs to a contract.
    //
    // Use Case: 
    // Helps prevent certain exploits by distinguishing contracts from EOAs.
    function isContract(address account) internal view returns(bool){
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    // Purpose: 
    // Sends Ether (amount) to a recipient address.
    //
    // How it works:
    // Verifies the contract has sufficient balance.
    // Uses call to transfer the specified amount.
    // Checks the success of the transfer.
    //
    // Use Case: 
    // Safely sending Ether without running into gas-related issues.
    function sendValue(address payable receipient, uint256 amount) internal{
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success,) = receipient.call{value: amount}(");
        require(success, "Address: unable to send value, receipient may have reverted");
    }


    // Purpose: Performs a low-level call to another contract.
    // How it works:
    // Calls the target contract with provided data.
    // Allows specifying an error message for debugging.
    // Delegates to functionCallWithValue with value set to 0.
    // Use Case: Safely invoking contract functions with error handling.
    function functionCall(address target, bytes memory data) internal returns(bytes memory){
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage,
    ) internal returns(bytes memory){
        return functionCallWithValue(target, data, 0, errorMessage);
    }


    //Purpose: Calls a contract and transfers Ether (value) along with the call.
    // How it works:
    // Ensures the contract has enough Ether.
    // Verifies that the target is a contract.
    // Uses call to send the call and funds.
    // Verifies the success of the call using verifyCallResult.
    // Use Case: Safe contract invocation with Ether transfer.
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns(bytes memory){
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string meory errorMessage
    ) internal returns(bytes memory){
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    // Purpose: Performs a staticcall to a contract. This is a read-only call that cannot modify state.
    // How it works:
    // Verifies the target is a contract.
    // Executes the staticcall.
    // Verifies the success of the call.
    // Use Case: For reading state or performing calculations in a contract without modifying its state.
    function functionStaticCall(
        address target,
        bytes memory data
    ) internal view returns(bytes memory){
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }


    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory){
        require(isContract(target), "Address: static call to non-contract");
        
        (bool success, bytes memory returndata) = target.staticall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    // Purpose: Executes a delegatecall to another contract. This runs in the context of the caller's contract, meaning storage and msg.sender are preserved.
    // How it works:
    // Ensures the target is a contract.
    // Executes the delegatecall.
    // Verifies the success of the call.
    // Use Case: Proxy patterns where logic is implemented in another contract but operates within the storage of the caller contract.
    function functionDelegateCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory){
        return functionDelegateCall(target, data, "Address: low-level delete call failed");
    }


    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory){
        require(isContract(target), "Address: delete call to non-contract");
        
        (bool success, bytes memory returndata) = target.delegatecall(data);
    }


    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory){
        if(success){
            return returndata;
        }else{
            if(returndata.length > 0){
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            }else{
                revert(errorMessage);
            }
        }
    }
    
}