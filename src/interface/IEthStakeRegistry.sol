// SPDX-License-Identifier: MIT
pragma solidity >=0.8.23 <0.9.0;

interface IEthStakeRegistry {
    function getUserStakingContract(address service, address user) external view returns (address);
    function getUserStakingContractBalance(address service, address user) external view returns (uint256);
    function stake(address user, bytes memory data) external payable;
    function unstake(address user, address payable to, uint256 amount, bytes memory data) external;
}
