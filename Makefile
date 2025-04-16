-include .env

.PHONY: test clean deploy snapshot format

# Clean the repo
clean:
	forge clean

## Compile artifacts
build:
	forge build

## Run tests
test:
	forge test

## Format
format:
	forge fmt

## Snapshot
snapshot:
	forge snapshot

## Deploy to Sepolia
deploy-sepolia:;
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --broadcast --account sepoliaKey --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv