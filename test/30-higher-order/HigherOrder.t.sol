// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

contract HigherOrderTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x716747Fbc1FcE4c36F2B369F87aDB5D4580e807f);
  }

  function testExploit() public {
    // ?
  }
}
