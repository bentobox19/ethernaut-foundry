// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

contract MagicNumberTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x200d3d9Ac7bFd556057224e7aEB4161fED5608D0);
  }

  function testExploit() public {
    // just read these
    // https://medium.com/coinmonks/ethernaut-lvl-19-magicnumber-walkthrough-how-to-deploy-contracts-using-raw-assembly-opcodes-c50edb0f71a2
    // https://cmichel.io/ethernaut-solutions/

    bytes memory bytecode = hex"600a600c600039600a6000f3602a60005260206000f3";
    bytes32 salt = 0;
    address solverAddress;

    assembly {
        solverAddress := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
    }

    (bool success,) = challengeAddress.call(abi.encodeWithSignature("setSolver(address)", solverAddress));
    success;

    utils.submitLevelInstance(challengeAddress);
  }
}
