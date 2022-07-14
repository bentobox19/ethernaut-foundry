// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

contract PrivacyTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x9b261b23cE149422DE75907C6ac0C30cEc4e652A);
  }

  function testExploit() public {
    // ?

    utils.submitLevelInstance(challengeAddress);
  }
}
