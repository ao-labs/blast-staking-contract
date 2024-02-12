// SPDX-License-Identifier: MIT
// solhint-disable
pragma solidity >=0.8.23 <0.9.0;

enum GasMode {
    VOID,
    CLAIMABLE
}

interface IGas {
    function readGasParams(address contractAddress) external view returns (uint256, uint256, uint256, GasMode);
    function setGasMode(address contractAddress, GasMode mode) external;
    function claimGasAtMinClaimRate(
        address contractAddress,
        address recipient,
        uint256 minClaimRateBips
    )
        external
        returns (uint256);
    function claimAll(address contractAddress, address recipient) external returns (uint256);
    function claimMax(address contractAddress, address recipient) external returns (uint256);
    function claim(
        address contractAddress,
        address recipient,
        uint256 gasToClaim,
        uint256 gasSecondsToConsume
    )
        external
        returns (uint256);
}

enum YieldMode {
    AUTOMATIC,
    VOID,
    CLAIMABLE
}

interface IYield {
    function configure(address contractAddress, uint8 flags) external returns (uint256);
    function claim(
        address contractAddress,
        address recipientOfYield,
        uint256 desiredAmount
    )
        external
        returns (uint256);
    function getClaimableAmount(address contractAddress) external view returns (uint256);
    function getConfiguration(address contractAddress) external view returns (uint8);
}

interface IBlast {
    // configure
    function configureContract(address contractAddress, YieldMode _yield, GasMode gasMode, address governor) external;
    function configure(YieldMode _yield, GasMode gasMode, address governor) external;

    // base configuration options
    function configureClaimableYield() external;
    function configureClaimableYieldOnBehalf(address contractAddress) external;
    function configureAutomaticYield() external;
    function configureAutomaticYieldOnBehalf(address contractAddress) external;
    function configureVoidYield() external;
    function configureVoidYieldOnBehalf(address contractAddress) external;
    function configureClaimableGas() external;
    function configureClaimableGasOnBehalf(address contractAddress) external;
    function configureVoidGas() external;
    function configureVoidGasOnBehalf(address contractAddress) external;
    function configureGovernor(address _governor) external;
    function configureGovernorOnBehalf(address _newGovernor, address contractAddress) external;

    // claim yield
    function claimYield(address contractAddress, address recipientOfYield, uint256 amount) external returns (uint256);
    function claimAllYield(address contractAddress, address recipientOfYield) external returns (uint256);

    // claim gas
    function claimAllGas(address contractAddress, address recipientOfGas) external returns (uint256);
    function claimGasAtMinClaimRate(
        address contractAddress,
        address recipientOfGas,
        uint256 minClaimRateBips
    )
        external
        returns (uint256);
    function claimMaxGas(address contractAddress, address recipientOfGas) external returns (uint256);
    function claimGas(
        address contractAddress,
        address recipientOfGas,
        uint256 gasToClaim,
        uint256 gasSecondsToConsume
    )
        external
        returns (uint256);

    // read functions
    function readClaimableYield(address contractAddress) external view returns (uint256);
    function readYieldConfiguration(address contractAddress) external view returns (uint8);
    function readGasParams(address contractAddress)
        external
        view
        returns (uint256 etherSeconds, uint256 etherBalance, uint256 lastUpdated, GasMode);
}

contract BlastMock is IBlast {
    function configureContract(
        address contractAddress,
        YieldMode _yield,
        GasMode gasMode,
        address governor
    )
        external
        override
    {
        // do nothing
    }

    function configure(YieldMode _yield, GasMode gasMode, address governor) external override {
        // do nothing
    }

    function configureClaimableYield() external override {
        // do nothing
    }

    function configureClaimableYieldOnBehalf(address contractAddress) external override {
        // do nothing
    }

    function configureAutomaticYield() external override {
        // do nothing
    }

    function configureAutomaticYieldOnBehalf(address contractAddress) external override {
        // do nothing
    }

    function configureVoidYield() external override {
        // do nothing
    }

    function configureVoidYieldOnBehalf(address contractAddress) external override {
        // do nothing
    }

    function configureClaimableGas() external override {
        // do nothing
    }

    function configureClaimableGasOnBehalf(address contractAddress) external override {
        // do nothing
    }

    function configureVoidGas() external override {
        // do nothing
    }

    function configureVoidGasOnBehalf(address contractAddress) external override {
        // do nothing
    }

    function configureGovernor(address _governor) external override {
        // do nothing
    }

    function configureGovernorOnBehalf(address _newGovernor, address contractAddress) external override {
        // do nothing
    }

    function claimYield(
        address contractAddress,
        address recipientOfYield,
        uint256 amount
    )
        external
        override
        returns (uint256)
    {
        // do nothing
        return 0;
    }

    function claimAllYield(address contractAddress, address recipientOfYield) external override returns (uint256) {
        // do nothing
        return 0;
    }

    function claimAllGas(address contractAddress, address recipientOfGas) external override returns (uint256) {
        // do nothing
        return 0;
    }

    function claimGasAtMinClaimRate(
        address contractAddress,
        address recipientOfGas,
        uint256 minClaimRateBips
    )
        external
        override
        returns (uint256)
    {
        // do nothing
        return 0;
    }

    function claimMaxGas(address contractAddress, address recipientOfGas) external override returns (uint256) {
        // do nothing
    }

    function claimGas(
        address contractAddress,
        address recipientOfGas,
        uint256 gasToClaim,
        uint256 gasSecondsToConsume
    )
        external
        override
        returns (uint256)
    {
        // do nothing
        return 0;
    }

    function readClaimableYield(address contractAddress) external view override returns (uint256) {
        // do nothing
        return 0;
    }

    function readYieldConfiguration(address contractAddress) external view override returns (uint8) {
        // do nothing
        return 0;
    }

    function readGasParams(address contractAddress)
        external
        view
        override
        returns (uint256 etherSeconds, uint256 etherBalance, uint256 lastUpdated, GasMode)
    {
        // do nothing
        return (0, 0, 0, GasMode.VOID);
    }
}
