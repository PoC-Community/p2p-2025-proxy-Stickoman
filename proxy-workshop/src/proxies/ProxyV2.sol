// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract ProxyV2 {
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

    constructor(address _implem) {
        setImplementation(_implem);
    }

    function _setImplementation(address newImplementation) internal {
        assembly {
            sstore(IMPLEMENTATION_SLOT, newImplementation)
        }
    }

    function setImplementation(address newImplementation) public virtual {
        _setImplementation(newImplementation);
    }

    function getImplementation() public view returns (address impl) {
        assembly {
            impl := sload(IMPLEMENTATION_SLOT)
        }
    }

    fallback() external payable {
        address impl = getImplementation();
        (bool success, bytes memory returnData) = impl.delegatecall(msg.data);
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

    receive() external payable {}
}
