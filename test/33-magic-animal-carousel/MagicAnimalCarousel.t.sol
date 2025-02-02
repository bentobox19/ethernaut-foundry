// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

contract MagicAnimalCarouselTest is Test {
  address private challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0xd8630853340e23CeD1bb87a760e2BaF095fb4009);
  }

  function testExploit() public {
    // TODO

    // utils.submitLevelInstance(challengeAddress);
  }
}
