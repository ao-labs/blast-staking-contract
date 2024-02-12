// SPDX-License-Identifier: MIT
pragma solidity >=0.8.23 <0.9.0;

import { EthStakeRegistry } from "../src/EthStakeRegistry.sol";

import { BaseScript } from "./Base.s.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract Deploy is BaseScript {
    function run() public broadcast returns (EthStakeRegistry ethStakeRegistry) {
        ethStakeRegistry = new EthStakeRegistry(
            vm.envOr("BLAST_CONTRACT", address(0x4300000000000000000000000000000000000002)),
            vm.envOr("GAS_COLLECTOR", address(0x0000000000000000000000000000000000000000))
        );
    }
}
