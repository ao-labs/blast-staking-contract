// SPDX-License-Identifier: MIT
pragma solidity >=0.8.23 <0.9.0;

interface IEthStakeHooks {
    function beforeStake(address user, uint256 amount, bytes memory data) external returns (bool);
    function afterStake(address user, uint256 amount, bytes memory data) external returns (bool);
    function beforeUnstake(address user, uint256 amount, bytes memory data) external returns (bool);
    function afterUnstake(address user, uint256 amount, bytes memory data) external returns (bool);
}
