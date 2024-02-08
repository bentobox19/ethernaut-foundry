// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

interface IMagicNumber {
  function setSolver(address) external;
}

contract MagicNumberTest is Test {
  address internal challengeAddress;
  IMagicNumber internal challenge;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x2132C7bc11De7A90B87375f282d36100a29f97a9);
    challenge = IMagicNumber(challengeAddress);
  }

  function testExploit() public {
    // we need to know the runtime opcodes first:
    // this is, mstore(0x80, 0x2a), then return it.
    // notice that the contract will always return 0x2a (good ole 42)
    // regardless the name of the function
    //
    // 602a    // v: push1 0x2a (value is 0x2a)
    // 6080    // p: push1 0x80 (memory slot is 0x80)
    // 52      // mstore
    //
    // 6020    // s: push1 0x20 (value is 32 bytes in size)
    // 6080    // p: push1 0x80 (value was stored in slot 0x80)
    // f3      // return
    //
    // resulting runtime opcodes is 602a60805260206080f3
    //
    // now we do the initialization code, as we know the runtime opcodes
    // are 10 bytes.
    //
    //
    // 600a    // s: push1 0x0a (10 bytes)
    // 600c    // f: push1 0x0c (current position of runtime opcodes)
    // 6000    // t: push1 0x00 (destination memory index 0)
    // 39      // CODECOPY
    //
    // 600a    // s: push1 0x0a (runtime opcode length)
    // 6000    // p: push1 0x00 (access memory index 0)
    // f3      // return to EVM
    //
    // resulting initialization opcodes is 600a600c600039600a6000f3
    //
    // putting everything together, we got 0x600a600c600039600a6000f3602a60805260206080f3

    // create the contract
    bytes memory bytecode = hex"600a600c600039600a6000f3602a60005260206000f3";
    bytes32 salt = 0;
    address solverAddress;

    assembly {
        solverAddress := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
    }

    // now we can assign this 10-byte size contract to the level
    challenge.setSolver(solverAddress);
    utils.submitLevelInstance(challengeAddress);
  }
}
