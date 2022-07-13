// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

interface IReentrance {
  function donate(address _to) external payable;
  function withdraw(uint _amount) external;
}

contract ElevatorTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0xaB4F3F2644060b2D960b0d88F0a42d1D27484687);
  }

  function testExploit() public {

    utils.submitLevelInstance(challengeAddress);
  }
}
