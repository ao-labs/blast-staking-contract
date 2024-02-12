// SPDX-License-Identifier: MIT
pragma solidity >=0.8.23;

import { IEthStakeHooks } from "../../src/interface/IEthStakeHooks.sol";
import { ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

contract StakeHookChecker is IEthStakeHooks, ERC165 {
    event BeforeStake(address user, uint256 amount, bytes data);
    event AfterStake(address user, uint256 amount, bytes data);
    event BeforeUnstake(address user, uint256 amount, bytes data);
    event AfterUnstake(address user, uint256 amount, bytes data);

    function beforeStake(address user, uint256 amount, bytes memory data) external override returns (bool) {
        emit BeforeStake(user, amount, data);
        return true;
    }

    function afterStake(address user, uint256 amount, bytes memory data) external override returns (bool) {
        emit AfterStake(user, amount, data);
        return true;
    }

    function beforeUnstake(address user, uint256 amount, bytes memory data) external override returns (bool) {
        emit BeforeUnstake(user, amount, data);
        return true;
    }

    function afterUnstake(address user, uint256 amount, bytes memory data) external override returns (bool) {
        emit AfterUnstake(user, amount, data);
        return true;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IEthStakeHooks).interfaceId || super.supportsInterface(interfaceId);
    }
}
