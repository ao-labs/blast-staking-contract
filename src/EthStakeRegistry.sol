// SPDX-License-Identifier: MIT
pragma solidity >=0.8.23 <0.9.0;

import { ExcessivelySafeCall } from "../lib/ExcessivelySafeCall/src/ExcessivelySafeCall.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { IBlast } from "./interface/IBlast.sol";
import { IBlastPoints } from "./interface/IBlastPoints.sol";
import { EthStakingContract } from "./EthStakingContract.sol";
import { IEthStakeRegistry } from "./interface/IEthStakeRegistry.sol";
import { IEthStakeHooks } from "../src/interface/IEthStakeHooks.sol";
import { ERC165Checker } from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { Error } from "./utils/Error.sol";

contract EthStakeRegistry is IEthStakeRegistry, Ownable, ReentrancyGuard, Error {
    using ExcessivelySafeCall for address;

    IBlast public immutable BLAST;
    IBlastPoints public immutable BLAST_POINTS;
    address public immutable STAKING_CONTRACT_IMPLEMENTATION;
    address public immutable BLAST_POINTS_OPERATOR;

    event Stake(address indexed service, address indexed user, uint256 amount);
    event Unstake(address indexed service, address indexed user, address indexed to, uint256 amount);
    event Log(string reason);

    uint256 public constant MAX_GAS_LIMIT = 3_000_000;

    /* ============ Constructor ============ */

    constructor(
        address blast,
        address blastPoints,
        address gasCollector,
        address pointsOperator
    )
        Ownable(gasCollector)
    {
        STAKING_CONTRACT_IMPLEMENTATION = address(new EthStakingContract());
        BLAST_POINTS_OPERATOR = pointsOperator;
        BLAST = IBlast(blast);
        BLAST.configureClaimableGas();
        BLAST.configureGovernor(gasCollector);
        BLAST_POINTS = IBlastPoints(blastPoints);
        BLAST_POINTS.configurePointsOperator(pointsOperator);
    }

    /* ============ Admin Gas Functions ============ */

    function claimAllGas(address contractAddress, address recipient) public onlyOwner {
        BLAST.claimAllGas(contractAddress, recipient);
    }

    function claimMaxGas(address contractAddress, address recipient) public onlyOwner {
        BLAST.claimMaxGas(contractAddress, recipient);
    }

    /* ============ External Functions ============ */

    function stake(address service, bytes memory data) external payable nonReentrant {
        if (msg.value == 0) {
            revert InvalidValue();
        }
        address userStakeContract = getUserStakingContract(service, msg.sender);
        if (!_isContract(userStakeContract)) {
            _deployStakingContract(service, msg.sender);
        }
        _beforeStake(service, msg.sender, msg.value, data);
        EthStakingContract(userStakeContract).deposit{ value: msg.value }();
        _afterStake(service, msg.sender, msg.value, data);
        emit Stake(service, msg.sender, msg.value);
    }

    function unstake(address service, address payable to, uint256 amount, bytes memory data) external nonReentrant {
        if (amount == 0) {
            revert InvalidValue();
        }
        address userStakeContract = getUserStakingContract(service, msg.sender);
        _beforeUnstake(service, msg.sender, amount, data);
        EthStakingContract(userStakeContract).withdraw(to, amount);
        _afterUnstake(service, msg.sender, amount, data);
        emit Unstake(service, msg.sender, to, amount);
    }

    /* ============ View Functions ============ */

    function getUserStakingContract(address service, address user) public view returns (address) {
        return Clones.predictDeterministicAddress(
            STAKING_CONTRACT_IMPLEMENTATION, keccak256(abi.encodePacked(service, user))
        );
    }

    function getUserStakingContractBalance(address service, address user) public view returns (uint256) {
        return getUserStakingContract(service, user).balance;
    }

    /* ============ Internal Functions ============ */

    function _isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function _deployStakingContract(address service, address user) internal {
        address stakingContract =
            Clones.cloneDeterministic(STAKING_CONTRACT_IMPLEMENTATION, keccak256(abi.encodePacked(service, user)));
        EthStakingContract(stakingContract).init(address(BLAST), address(BLAST_POINTS), service, BLAST_POINTS_OPERATOR);
    }

    function _beforeStake(address service, address user, uint256 amount, bytes memory data) internal {
        if (ERC165Checker.supportsInterface(service, type(IEthStakeHooks).interfaceId)) {
            (bool success,) = service.excessivelySafeCall(
                MAX_GAS_LIMIT, 0, 0, abi.encodeWithSelector(IEthStakeHooks.beforeStake.selector, user, amount, data)
            );
            if (!success) {
                emit Log("beforeStakeError");
            }
        }
    }

    function _afterStake(address service, address user, uint256 amount, bytes memory data) internal {
        if (ERC165Checker.supportsInterface(service, type(IEthStakeHooks).interfaceId)) {
            (bool success,) = service.excessivelySafeCall(
                MAX_GAS_LIMIT, 0, 0, abi.encodeWithSelector(IEthStakeHooks.afterStake.selector, user, amount, data)
            );
            if (!success) {
                emit Log("afterStakeError");
            }
        }
    }

    function _beforeUnstake(address service, address user, uint256 amount, bytes memory data) internal {
        if (ERC165Checker.supportsInterface(service, type(IEthStakeHooks).interfaceId)) {
            (bool success,) = service.excessivelySafeCall(
                MAX_GAS_LIMIT, 0, 0, abi.encodeWithSelector(IEthStakeHooks.beforeUnstake.selector, user, amount, data)
            );
            if (!success) {
                emit Log("beforeUnstakeError");
            }
        }
    }

    function _afterUnstake(address service, address user, uint256 amount, bytes memory data) internal {
        if (ERC165Checker.supportsInterface(service, type(IEthStakeHooks).interfaceId)) {
            (bool success,) = service.excessivelySafeCall(
                MAX_GAS_LIMIT, 0, 0, abi.encodeWithSelector(IEthStakeHooks.afterUnstake.selector, user, amount, data)
            );
            if (!success) {
                emit Log("afterUnstakeError");
            }
        }
    }
}
