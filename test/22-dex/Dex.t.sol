// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

contract DexTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0xC084FC117324D7C628dBC41F17CAcAaF4765f49e);
  }

  function testExploit() public {
    // ?

    // utils.submitLevelInstance(challengeAddress);
  }
}
