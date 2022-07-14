// 0x11343d543778213221516D004ED82C45C3c8788B


// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

contract PrivacyTest is Test {
  address internal challengeAddress;
  Building internal building;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0xaB4F3F2644060b2D960b0d88F0a42d1D27484687);
    building = new Building(challengeAddress);
  }

  function testExploit() public {
    building.solveChallenge();

    utils.submitLevelInstance(challengeAddress);
  }
}
