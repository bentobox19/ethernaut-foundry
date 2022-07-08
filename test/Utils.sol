// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";

interface ILevel {}

interface IEthernaut {
  function createLevelInstance(ILevel) external;
  function submitLevelInstance(address payable) external;
}

contract Utils is Test {
  IEthernaut internal ethernaut;
  address internal constant ETHERNAUT_ADDRESS = 0xD991431D8b033ddCb84dAD257f4821E9d5b38C33;

  constructor() {
    ethernaut = IEthernaut(ETHERNAUT_ADDRESS);
  }

  function createLevelInstance(address _levelFactory) external returns (address) {
    ILevel level = ILevel(_levelFactory);

    vm.recordLogs();
    ethernaut.createLevelInstance(level);

    Vm.Log[] memory entries = vm.getRecordedLogs();

    return address(abi.decode(entries[0].data, (address)));
  }

  function submitLevelInstance(address _instance) external {
    vm.recordLogs();
    ethernaut.submitLevelInstance(payable(_instance));

    Vm.Log[] memory entries = vm.getRecordedLogs();

    require(entries.length > 0);
  }
}
