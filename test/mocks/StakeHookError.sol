// SPDX-License-Identifier: MIT
// solhint-disable
pragma solidity >=0.8.23;

import { IEthStakeHooks } from "../../src/interface/IEthStakeHooks.sol";
import { ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

contract StakeHookError is IEthStakeHooks, ERC165 {
    function beforeStake(address user, uint256 amount, bytes memory data) external override returns (bool) {
        revert("beforeStakeError");
        return true;
    }

    function afterStake(address user, uint256 amount, bytes memory data) external override returns (bool) {
        require(false, "afterStakeError");
        return true;
    }

    function beforeUnstake(address user, uint256 amount, bytes memory data) external override returns (bool) {
        for (uint256 i = 0; i < 100_000_000; i++) {
            keccak256("use up some gas");
        }
        return true;
    }

    function afterUnstake(address user, uint256 amount, bytes memory data) external override returns (bool) {
        return false;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IEthStakeHooks).interfaceId || super.supportsInterface(interfaceId);
    }
}
