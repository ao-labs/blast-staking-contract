// SPDX-License-Identifier: MIT
pragma solidity >=0.8.23 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

import { EthStakeRegistry } from "../src/EthStakeRegistry.sol";
import { StakeHookChecker } from "./mocks/StakeHookChecker.sol";
import { StakeHookError } from "./mocks/StakeHookError.sol";
import { IBlast } from "./mocks/BlastMock.sol";
import { BlastMock } from "./mocks/BlastMock.sol";

contract EthStakeRegistryTest is PRBTest, StdCheats {
    EthStakeRegistry internal ethStakeRegistry;
    address public governor;
    address public service;
    address public user1;
    address public user2;
    IBlast public blast;

    function setUp() public virtual {
        // @dev Yeild related functions reverts when testing with a fork
        // @TODO When problem fixes, uncomment
        // vm.createSelectFork({ urlOrAlias: "blast_sepolia", blockNumber: 1_518_004 });
        // blast = IBlast(vm.envOr("BLAST_CONTRACT_ADDRESS", address(0x4300000000000000000000000000000000000002)));
        blast = new BlastMock();
        governor = vm.addr(1);
        service = vm.addr(2);
        user1 = vm.addr(3);
        user2 = vm.addr(4);
        ethStakeRegistry = new EthStakeRegistry(address(blast), governor);
    }

    function test_Stake() external {
        vm.deal(user1, 100);
        vm.startPrank(user1);
        assertEq(ethStakeRegistry.getUserStakingContractBalance(service, user1), 0);
        ethStakeRegistry.stake{ value: 100 }(service, "");
        assertEq(ethStakeRegistry.getUserStakingContractBalance(service, user1), 100);
        assertEq(ethStakeRegistry.getUserStakingContract(service, user1).balance, 100);
        assertEq(user1.balance, 0);
    }

    function test_Withdraw() external {
        vm.deal(user1, 100);
        vm.startPrank(user1);
        ethStakeRegistry.stake{ value: 100 }(service, "");
        ethStakeRegistry.unstake(service, payable(user2), 50, "");
        assertEq(ethStakeRegistry.getUserStakingContractBalance(service, user1), 50);
        assertEq(user2.balance, 50);

        ethStakeRegistry.unstake(service, payable(user1), 50, "");
        assertEq(ethStakeRegistry.getUserStakingContractBalance(service, user1), 0);
        assertEq(user1.balance, 50);

        vm.expectRevert();
        ethStakeRegistry.unstake(user1, payable(user2), 50, "");
    }

    function testFuzz_Stake(uint256 x) external {
        vm.assume(x > 0);
        vm.startPrank(user1);
        vm.deal(user1, x);
        ethStakeRegistry.stake{ value: x }(service, "");
        assertEq(ethStakeRegistry.getUserStakingContractBalance(service, user1), x);

        vm.expectRevert();
        ethStakeRegistry.unstake(service, payable(user2), x + 1, "");

        ethStakeRegistry.unstake(service, payable(user2), x, "");
        assertEq(ethStakeRegistry.getUserStakingContractBalance(service, user1), 0);
    }

    event BeforeStake(address user, uint256 amount, bytes data);
    event AfterStake(address user, uint256 amount, bytes data);
    event BeforeUnstake(address user, uint256 amount, bytes data);
    event AfterUnstake(address user, uint256 amount, bytes data);

    function test_StakeHook() external {
        StakeHookChecker hookChecker = new StakeHookChecker();

        vm.startPrank(user1);
        vm.deal(user1, 1000);
        vm.expectEmit(true, true, true, true);
        emit BeforeStake(user1, 100, "beforeStake");
        ethStakeRegistry.stake{ value: 100 }(address(hookChecker), "beforeStake");

        vm.expectEmit(true, true, true, true);
        emit AfterStake(user1, 200, "afterStake");
        ethStakeRegistry.stake{ value: 200 }(address(hookChecker), "afterStake");

        vm.expectEmit(true, true, true, true);
        emit BeforeUnstake(user1, 100, "beforeUnstake");
        ethStakeRegistry.unstake(address(hookChecker), payable(user2), 100, "beforeUnstake");

        vm.expectEmit(true, true, true, true);
        emit AfterUnstake(user1, 200, "afterUnstake");
        ethStakeRegistry.unstake(address(hookChecker), payable(user2), 200, "afterUnstake");
    }

    function test_StakeHookError() external {
        StakeHookError hookError = new StakeHookError();

        vm.startPrank(user1);
        vm.deal(user1, 1000);
        vm.expectEmit(true, true, true, true);
        emit Log("beforeStakeError");
        ethStakeRegistry.stake{ value: 100 }(address(hookError), "beforeStake");

        vm.expectEmit(true, true, true, true);
        emit Log("afterStakeError");
        ethStakeRegistry.stake{ value: 200 }(address(hookError), "afterStake");

        vm.expectEmit(true, true, true, true);
        emit LogBytes(""); // out of gas error
        ethStakeRegistry.unstake(address(hookError), payable(user2), 100, "beforeUnstake");

        vm.expectEmit(true, true, true, true);
        emit Log("error");
        ethStakeRegistry.unstake(address(hookError), payable(user2), 200, "afterUnstake");
    }
}
