# Write Up

## 00 Hello

### Solution 1

Just read the factory contract

```solidity
return address(new Instance('ethernaut0'));
```

And call the function

```solidity
function testExploit1() public {
    // password can be observed from the factory contract
    challenge.authenticate("ethernaut0");

    utils.submitLevelInstance(challengeAddress);
}
```

### Solution 2

Suppose we don't have the factory file at hand, but we can read the blockchain. We do that and call the function with the found value.

To simplify things (we can always check the lowest bit), assume we know beforehand the string is at most 31 bytes long. Since  the first slot (`0`) is giving us the value `0x65746865726e6175743000000000000000000000000000000000000000000014`, we can conclude the string is length `10` bytes (`0x14` = `20` = `2 * 20 bytes`), and the string is `0x65746865726e61757430`. Take it to CyberChef to verify is `ethernaut0`:

https://gchq.github.io/CyberChef/#recipe=From_Hex('Auto')&input=MHg2NTc0Njg2NTcyNmU2MTc1NzQzMA

Then we know we have to read the first 10 bytes from the slot `0` and convert it to a string in order to use it as a variable.

```solidity
// alternate solution: you can't read the factory.
// you can always read the blockchain though
function testExploit() public {

  // get the contents of the slot 0 from the challenge address,
  // assuming that this is a string with less than 32 bytes,
  // in that case, length the lowest-order byte stores the value length * 2.
  bytes32 slot0 = vm.load(challengeAddress, bytes32(uint256(0)));
  uint8 len = uint8(slot0[31]) / 2;

  bytes memory password = new bytes(len);

  for (uint8 i = 0; i < len; i++) {
    password[i] = slot0[i];
  }

  // test the found password in the contract
  challenge.authenticate(string(password));

  utils.submitLevelInstance(challengeAddress);
}
```

### References

* https://docs.soliditylang.org/en/v0.8.18/internals/layout_in_storage.html

> In particular: if the data is at most 31 bytes long, the elements are stored
> in the higher-order bytes (left aligned) and the lowest-order byte stores the value length * 2.
> For byte arrays that store data which is 32 or more bytes long, the main slot p stores length * 2 + 1 and the data is stored as usual in `keccak256(p)`. This means that you can distinguish a short array from a long array by checking if the lowest bit is set: short (not set) and long (set).

* https://betterprogramming.pub/all-about-solidity-data-locations-part-i-storage-e50604bfc1ad
    * Long, comprehensive article
* https://www.adrianhetman.com/unboxing-evm-storage/
    * Matter of fact article
* https://blog.openzeppelin.com/ethereum-in-depth-part-2-6339cf6bddb9/
    * See `Storage` section. Includes assembly.
