// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

interface ITarget {
  function init(uint256) external;
  function setMaxBalance(uint256) external;
}

contract PuzzleWalletTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0xe13a4a46C346154C41360AAe7f070943F67743c9, 0.001 ether);
  }

  function testExploit() public {
    // challengeAddress is the proxy
    // let's read its storage

    console.logBytes32(vm.load(challengeAddress, bytes32(uint256(0))));
    console.logBytes32(vm.load(challengeAddress, bytes32(uint256(1))));
    console.logBytes32(vm.load(challengeAddress, bytes32(uint256(2))));
    console.logBytes32(vm.load(challengeAddress, bytes32(uint256(2))));

    ITarget target = ITarget(challengeAddress);
    target.setMaxBalance(20);



    // nota
    // leer esto para cachar del storage en los proxies
    // https://docs.openzeppelin.com/upgrades-plugins/1.x/proxies#unstructured-storage-proxies

    // utils.submitLevelInstance(challengeAddress);
  }
}
