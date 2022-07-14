// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

contract GatekeeperTwoTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0xdCeA38B2ce1768E1F409B6C65344E81F16bEc38d);
  }

  function testExploit() public {
    // ?

    utils.submitLevelInstance(challengeAddress);
  }
}
