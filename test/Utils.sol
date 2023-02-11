// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Vm.sol";

interface ILevel {}

interface IEthernaut {
  function createLevelInstance(ILevel) external payable;
  function submitLevelInstance(address payable) external;
}

library utils {
  Vm public constant vm = Vm(address(bytes20(uint160(uint256(keccak256('hevm cheat code'))))));
  IEthernaut internal constant ethernaut = IEthernaut(0xD2e5e0102E55a5234379DD796b8c641cd5996Efd);

  function createLevelInstance(address _levelFactory) external returns (address) {
    return _createLevelInstance(_levelFactory, 0);
  }

  function createLevelInstance(address _levelFactory, uint256 _value) external returns (address) {
    return _createLevelInstance(_levelFactory, _value);
  }

  function _createLevelInstance(address _levelFactory, uint256 _value) private returns (address) {
    ILevel level = ILevel(_levelFactory);

    vm.recordLogs();
    ethernaut.createLevelInstance{value: _value}(level);

    Vm.Log[] memory entries = vm.getRecordedLogs();

    return address(uint160(uint256(entries[entries.length - 1].topics[2])));
  }

  function submitLevelInstance(address _instance) external {
    vm.recordLogs();
    ethernaut.submitLevelInstance(payable(_instance));

    Vm.Log[] memory entries = vm.getRecordedLogs();

    require(entries.length > 0);
  }
}
