// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./ProxyV2.sol";

contract ProxyOwnableUpgradable is ProxyV2 {
    bytes32 private constant OWNER_SLOT = bytes32(uint256(keccak256("eip1967.proxy.owner")) - 1);

    event Upgraded(address indexed implementation);
    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    constructor(address _owner, address _implem) ProxyV2(_implem) {
        _setOwner(_owner);
    }

    modifier onlyOwner() {
        require(msg.sender == getOwner(), "Not owner");
        _;
    }

    function _setOwner(address newOwner) internal {
        assembly {
            sstore(OWNER_SLOT, newOwner)
        }
    }

    function getOwner() public view returns (address owner) {
        assembly {
            owner := sload(OWNER_SLOT)
        }
    }

    function transferProxyOwnership(address newOwner) public onlyOwner {
        emit ProxyOwnershipTransferred(getOwner(), newOwner);
        _setOwner(newOwner);
    }

    function upgradeTo(address newImplementation) public onlyOwner {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function setImplementation(address newImplementation) public override onlyOwner {
        _setImplementation(newImplementation);
    }
}
