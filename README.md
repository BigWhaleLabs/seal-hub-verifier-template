# SealHub verifier template

Circom template to be used to verify a SealHub commitment.

## Usage

1. Clone the repository with `git clone git@github.com:BigWhaleLabs/seal-hub-verifier-template.git`
2. Install the dependencies with `yarn`
3. Add environment variables to your `.env` file
4. Check out `yarn generate-inputs` script to get inputs
5. Run `yarn compile` to compile the circom circuits, create proof, verify proof, export verifier as a solidity Verifier.sol
6. Run `yarn test` to run the test suits
7. Use the artifacts from the `public` folder in [snarkjs](https://github.com/iden3/snarkjs)
8. Run `yarn deploy` to deploy the verifier smart contracts to blockchain
9. Run `yarn release` to publish an NPM package with typings that can later be used in any of your JS/TS projects

## Environment variables

| Name                         | Description                       |
| ---------------------------- | --------------------------------- |
| `ETHERSCAN_API_KEY`          | Etherscan API key                 |
| `ETH_RPC`                    | Ethereum RPC URL                  |
| `CONTRACT_OWNER_PRIVATE_KEY` | Private key of the contract owner |

Also check out the `.env.example` file for more information.

## Available scripts

- `yarn build` — compiles the contracts' ts interfaces to the `typechain` directory
- `yarn compile` - compiles the circom circuit, creates proof, verifies proof, exports verifier as a solidity file, exports artifacts to the `public` directory
- `yarn test` — runs the test suite
- `yarn deploy` — deploys the contract to the network
- `yarn eth-lint` — runs the linter for the solidity contracts
- `yarn lint` — runs all the linters
- `yarn prettify` — prettifies the code in th project
- `yarn release` — relases the `typechain` directory to NPM
- `yarn download-ptau` — downloads the correct ptau file
