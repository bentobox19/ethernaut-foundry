// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface ILevel {
  function createInstance(address) external returns (address);
  function validateInstance(address payable, address) external returns (bool);
}

interface IEthernaut {
  function createLevelInstance(ILevel) external;
  function submitLevelInstance(address payable) external;
}

contract Utils {
  address internal constant ETHERNAUT_ADDRESS = 0xD991431D8b033ddCb84dAD257f4821E9d5b38C33;

  function createLevelInstance(address _levelFactory) public returns (address) {
    IEthernaut ethernaut = IEthernaut(ETHERNAUT_ADDRESS);
    ILevel level = ILevel(_levelFactory);

    ethernaut.createLevelInstance(level);

    // TODO
    // Record the event to get the address!
  }

  // TODO
  // Implement
  function submitLevelInstance() public {
    // ?
  }
}

// TOOD
// Put the code below inside the contract

/*
bytes32 internal nextUser = keccak256(abi.encodePacked("user address"));

function getNextUserAddress() external returns (address payable) {
    //bytes32 to address conversion
    address payable user = payable(address(uint160(uint256(nextUser))));
    nextUser = keccak256(abi.encodePacked(nextUser));
    return user;
}

/// @notice create users with 100 ether balance
function createUsers(uint256 userNum)
    external
    returns (address payable[] memory)
{
    address payable[] memory users = new address payable[](userNum);
    for (uint256 i = 0; i < userNum; i++) {
        address payable user = this.getNextUserAddress();
        vm.deal(user, 100 ether);
        users[i] = user;
    }
    return users;
}

/// @notice move block.number forward by a given number of blocks
function mineBlocks(uint256 numBlocks) external {
    uint256 targetBlock = block.number + numBlocks;
    vm.roll(targetBlock);
}
*/
