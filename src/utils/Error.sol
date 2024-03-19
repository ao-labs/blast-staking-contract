// SPDX-License-Identifier: MIT
pragma solidity >=0.8.23 <0.9.0;

/// @title Error contract
/// @dev Contracts should inherit from this contract to use custom errors
contract Error {
    error OnlyStakeRegistry();
    error InvalidValue();
    error WithdrawalFailed();
}
