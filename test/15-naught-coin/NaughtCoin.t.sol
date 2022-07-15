// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

contract NaughtCoinTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x096bb5e93a204BfD701502EB6EF266a950217218);
  }

  function testExploit() public {

    // utils.submitLevelInstance(challengeAddress);
  }
}
