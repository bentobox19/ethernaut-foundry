# ethernaut-foundry

* Porting in [foundry-rs](https://github.com/foundry-rs/foundry) of the solutions for [The Ethernaut CTF](https://github.com/OpenZeppelin/ethernaut).

## Writeups

* Discussion of the solutions at the [writeups.md](writeups.md) document.

## Install forge

* Follow the [instructions](https://book.getfoundry.sh/getting-started/installation.html) to install [Foundry](https://github.com/foundry-rs/foundry).

## Install dependencies

```bash
forge install
```

## Run the entire test suit

### Preparations

Create an `.env` file. You can copy the sample `.env-sample`:

```
export RPC_URL=https://eth-holesky.g.alchemy.com/v2/9yUn7YrS814EkZ-2xI0Ex0VFHcPAUmRw
export BLOCK_NUMBER=2000000
```

Then you just do

```bash
forge test
```

## Running a single challenge

```bash
forge test --match-contract Hello
```

### Add traces

There are different level of verbosities, `-vvvvv` is the maximum.

```bash
forge test --match-contract Hello -vvvvv
```
