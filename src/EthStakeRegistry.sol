// SPDX-License-Identifier: MIT
pragma solidity >=0.8.23 <0.9.0;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { IBlast } from "./interface/IBlast.sol";
import { EthStakingContract } from "./EthStakingContract.sol";
import { IEthStakeRegistry } from "./interface/IEthStakeRegistry.sol";
import { IEthStakeHooks } from "../src/interface/IEthStakeHooks.sol";
import { ERC165Checker } from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import { Error } from "./Utils/Error.sol";

contract EthStakeRegistry is IEthStakeRegistry, Ownable, Error {
    IBlast public immutable BLAST;
    address public immutable STAKING_CONTRACT_IMPLEMENTATION;

    mapping(address service => address blastPointsAdmin) public serviceToBlastPointsAdmin;

    event SetBlastPointsAdmin(address service, address blastPointsAdmin);
    event Stake(address indexed service, address indexed user, uint256 amount);
    event Unstake(address indexed service, address indexed user, address indexed to, uint256 amount);
    event Log(string reason);
    event LogBytes(bytes reason);

    // @TODO determine whether 300k is reasonable
    uint256 public constant MAX_GAS_LIMIT = 300_000; // @dev gas limit for hooks

    /* ============ Constructor ============ */

    constructor(address blast, address gasCollector) payable Ownable(gasCollector) {
        STAKING_CONTRACT_IMPLEMENTATION = address(new EthStakingContract());
        BLAST = IBlast(blast);
        BLAST.configureClaimableGas();
        BLAST.configureGovernor(gasCollector);
    }

    /* ============ Admin Gas Functions ============ */

    function claimAllGas(address contractAddress, address recipient) public onlyOwner {
        BLAST.claimAllGas(contractAddress, recipient);
    }

    function claimMaxGas(address contractAddress, address recipient) public onlyOwner {
        BLAST.claimMaxGas(contractAddress, recipient);
    }

    /* ============ External Functions ============ */

    function setBlastPointsAdmin(address blastPointsAdmin) external {
        serviceToBlastPointsAdmin[msg.sender] = blastPointsAdmin;
        emit SetBlastPointsAdmin(msg.sender, blastPointsAdmin);
    }

    function stake(address service, bytes memory data) external payable {
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

    function unstake(address service, address payable to, uint256 amount, bytes memory data) external {
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

    function getBlastPointsAdmin(address service) external view returns (address) {
        return serviceToBlastPointsAdmin[service];
    }

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
        EthStakingContract(stakingContract).init(address(BLAST), service);
    }

    function _beforeStake(address service, address user, uint256 amount, bytes memory data) internal {
        if (ERC165Checker.supportsInterface(service, type(IEthStakeHooks).interfaceId)) {
            try IEthStakeHooks(service).beforeStake{ gas: MAX_GAS_LIMIT }(user, amount, data) returns (bool success) {
                if (!success) {
                    emit Log("error");
                }
            } catch Error(string memory reason) {
                emit Log(reason);
            } catch (bytes memory reason) {
                emit LogBytes(reason);
            }
        }
    }

    function _afterStake(address service, address user, uint256 amount, bytes memory data) internal {
        if (ERC165Checker.supportsInterface(service, type(IEthStakeHooks).interfaceId)) {
            try IEthStakeHooks(service).afterStake{ gas: MAX_GAS_LIMIT }(user, amount, data) returns (bool success) {
                if (!success) {
                    emit Log("error");
                }
            } catch Error(string memory reason) {
                emit Log(reason);
            } catch (bytes memory reason) {
                emit LogBytes(reason);
            }
        }
    }

    function _beforeUnstake(address service, address user, uint256 amount, bytes memory data) internal {
        if (ERC165Checker.supportsInterface(service, type(IEthStakeHooks).interfaceId)) {
            try IEthStakeHooks(service).beforeUnstake{ gas: MAX_GAS_LIMIT }(user, amount, data) returns (bool success) {
                if (!success) {
                    emit Log("error");
                }
            } catch Error(string memory reason) {
                emit Log(reason);
            } catch (bytes memory reason) {
                emit LogBytes(reason);
            }
        }
    }

    function _afterUnstake(address service, address user, uint256 amount, bytes memory data) internal {
        if (ERC165Checker.supportsInterface(service, type(IEthStakeHooks).interfaceId)) {
            try IEthStakeHooks(service).afterUnstake{ gas: MAX_GAS_LIMIT }(user, amount, data) returns (bool success) {
                if (!success) {
                    emit Log("error");
                }
            } catch Error(string memory reason) {
                emit Log(reason);
            } catch (bytes memory reason) {
                emit LogBytes(reason);
            }
        }
    }
}
