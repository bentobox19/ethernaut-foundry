// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

contract CoinFlipTest is Test {

  function setUp() public {
    // CREATION OF THE INSTANCE
    // SET UP OF USERS AND BLA
  }

  function testExploit() public {
    // HERE GOES THE EXPLOIT

    validation();
  }

  function validation() private {
    // TESTING CONDITIONS
  }
}

// BELOW IS THE JS CODE FROM HARDHAT

/*
before(async () => {
  const challengeFactory = await ethers.getContractFactory("CoinFlip");
  challengeAddress = await createChallenge(
    "0x4dF32584890A0026e56f7535d0f2C6486753624f"
  );
  challenge = await challengeFactory.attach(challengeAddress)

  const attackerFactory = await ethers.getContractFactory("CoinFlipAttack");
  attacker = await attackerFactory.deploy();
});

it("solves ethernaut 03-coinflip", async function () {
  for (let i = 0; i < 10; i++) {
    await attacker.attack(challengeAddress);

    // simulate waiting 1 block
    await ethers.provider.send("evm_increaseTime", [1]);
    await ethers.provider.send("evm_mine", []);

    // console.log((await challenge.consecutiveWins()))
  }
});

after(async () => {
  expect(await submitLevel(challenge.address), "level not solved").to.be.true;
});
*/
