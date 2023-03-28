// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

contract GoodSamaritanTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x8d07AC34D8f73e2892496c15223297e5B22B3ABE);
  }

  function testExploit() public {
    // utils.submitLevelInstance(challengeAddress);
  }
}
