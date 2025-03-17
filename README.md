# Solidity training

Now using Foundry for the training.

## Resulting artifacts

SimpleStorage ([0x27bc4fdf04772d846c6ae95ef23bd7d9e481161f](https://sepolia.etherscan.io/address/0x27bc4fdf04772d846c6ae95ef23bd7d9e481161f#code))
— stores people's name and a corresponding favourite number.

## Tips

* Use `cast` to store pks: `cast wallet import defaultKey --interactive` for setting up a default pk
  used, `cast wallet list` to list all the added pks. In a contract deployment command, in terminal,
  use `--account defaultKey`.
* Use `cast` to interact with a contract deployed locally to anvil, e.g., store a
  value `cast send contractAddress "store(uint256)" 345 --account defaultKey`, retrieve the
  result `cast call contractAddress "retrieve()"`, cast the result to decimals to check the
  value `cast --to-base obtainedHexValue dec `.

## Framework of choice

Foundry — a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

### Docs and installation

[Get started](https://book.getfoundry.sh/getting-started/installation) with Foundry.

### Usage

* Build — `forge build`
* Tes — `forge test`
* Format — `forge fmt`
* Gas snapshots — `forge snapshot`
* Anvil — `anvil`
* Deploy — `forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>`
* Cast — `cast <subcommand>`, e.g. `cast call senderPublicKey "retrieve()"`
* Help — `forge --help`, `anvil --help`, `cast --help`
