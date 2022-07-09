// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Vm.sol";

interface ILevel {}

interface IEthernaut {
  function createLevelInstance(ILevel) external;
  function submitLevelInstance(address payable) external;
}

library utils {
  Vm public constant vm = Vm(address(bytes20(uint160(uint256(keccak256('hevm cheat code'))))));
  IEthernaut internal constant ethernaut = IEthernaut(0xD991431D8b033ddCb84dAD257f4821E9d5b38C33);

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
