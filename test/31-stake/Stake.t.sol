// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

contract StakeTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x32FFB8d4244B350F5D3E074e9b731A135531B975);
  }

  function testExploit() public {
    // ???

    // utils.submitLevelInstance(challengeAddress);
  }
}
