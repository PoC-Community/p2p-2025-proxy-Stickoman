// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract ProxyV1 {
    uint256 public count;
    address public implem;

    constructor(address _implem) {
        implem = _implem;
        count = 0;
    }

    receive() external payable {}

    function implementation() public view returns (address) {
        return implem;
    }

    fallback() external payable {
        (bool success, bytes memory returnData) = implem.delegatecall(msg.data);
        if (!success) {
            if (returnData.length > 0) {
                assembly {
                    let returndata_size := mload(returnData)
                    revert(add(32, returnData), returndata_size)
                }
            } else {
                revert("Delegatecall failed");
            }
        }
        assembly {
            return(add(returnData, 32), mload(returnData))
        }
    }
}
