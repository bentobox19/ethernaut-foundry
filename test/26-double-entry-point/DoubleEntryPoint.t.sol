// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

// setting interfaces for DoubleEntryPoint and Forta
// makes the code more readable than just issuing `.call{}()`
interface IDoubleEntryPoint {
  function forta() external returns (IForta);
}

interface IForta {
  function setDetectionBot(address detectionBotAddress) external;
  function raiseAlert(address user) external;
}

contract DetectionBot {
  IForta forta;

  constructor(address _fortaAddress) {
    forta = IForta(_fortaAddress);
  }

  // this is the simplest solution:
  // we just want _any_ transfer to fail in this level.
  // if we were to add some logic, we need to examine the second parameter,
  // to allow some transactions, while preventing others.
  function handleTransaction(address user, bytes calldata) public {
    forta.raiseAlert(user);
  }
}

contract DoubleEntryPointTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0xAd703241B7118b688E3a8D389036f8495224BE68);
  }

  function testExploit() public {
    // we need to know the forta instance address to set the detection bot
    IDoubleEntryPoint doubleEntryPoint = IDoubleEntryPoint(challengeAddress);
    IForta forta = doubleEntryPoint.forta();

    // set the detection bot
    DetectionBot myDetectionBot = new DetectionBot(address(forta));
    forta.setDetectionBot(address(myDetectionBot));

    utils.submitLevelInstance(challengeAddress);
  }
}
