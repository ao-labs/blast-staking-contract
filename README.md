# Blast Staking Contract

The Blast Staking Contract offers a flexible and user-centric approach to staking on BLAST, allowing users to stake ether with the potential for automatic yield. It emphasizes user autonomy by ensuring that individuals have full control over their deposits and yields, despite the service's role in managing BLAST points. Utilizing the ERC 1167 minimal proxy contract, it deploys individual staking contracts for users, aiming for precise yield distribution and enhancing the overall staking experience.

The Blast Staking Contract also empowers services to claim BLAST points, offering them the flexibility to distribute these rewards to users. This feature enhances the staking ecosystem by allowing services to provide additional value and incentives, enriching the user experience.

### Features

#### Open Integration
Designed for any service to integrate, providing a versatile staking solution.
#### User Control
Users maintain control over their assets, with no service intervention in staking or unstaking processes.
#### Hooks
Services can adopt the IEthStakeHooks interface to utilize a sophisticated hook system, facilitating custom actions before and after staking or unstaking. This allows for enriched service interactions tailored to specific user activities.
#### Blast Points Administration
By designating a Blast Points admin via setBlastPointsAdmin, services gain the capability to claim Blast Points. This feature empowers services to distribute rewards among users, enhancing the overall staking experience and incentivizing participation.


### Environment Setup
Before deploying and interacting with the EthStaking Contracts, you need to configure your development environment. Copy the content below into a .env file and replace placeholders

### Build

Build the contracts:

```sh
$ forge build
```

### Clean

Delete the build artifacts and cache directories:

```sh
$ forge clean
```

### Compile

Compile the contracts:

```sh
$ forge build
```

### Coverage

Get a test coverage report:

```sh
$ forge coverage
```

### Deploy

```sh
$ forge script script/Deploy.s.sol --broadcast --fork-url http://localhost:8545
```

or 

```sh
$ bun run deploy:sepolia
```

### Test

Run the tests:

```sh
$ forge test
```

Generate test coverage and output result to the terminal:

```sh
$ bun run test:coverage
```

## License

MIT
