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

```bash
forge test --fork-url https://eth-goerli.g.alchemy.com/v2/<API-KEY> --fork-block-number 9500000
```

## Running a single challenge

```bash
forge test --fork-url https://eth-goerli.g.alchemy.com/v2/<API-KEY> --fork-block-number 9500000 --match-contract Hello
```

### Add traces

There are different level of verbosities, `-vvvvv` is the maximum.

```bash
forge test --fork-url https://eth-goerli.g.alchemy.com/v2/<API-KEY> --fork-block-number 9500000 --match-contract Hello -vvvvv
```
