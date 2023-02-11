// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

interface IInstance {
  function authenticate(string memory passkey) external;
}

contract HelloTest is Test {
  address internal challengeAddress;
  IInstance internal challenge;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0xBA97454449c10a0F04297022646E7750b8954EE8);
    challenge = IInstance(challengeAddress);
  }

  function testExploit() public {
    // password can be observed from the factory contract
    challenge.authenticate("ethernaut0");

    utils.submitLevelInstance(challengeAddress);
  }
}
