// SPDX-License-Identifier: MIT
pragma solidity >=0.8.23 <0.9.0;

import { IBlast, YieldMode, GasMode } from "./interface/IBlast.sol";
import { IBlastPoints } from "./interface/IBlastPoints.sol";
import { IEthStakeRegistry } from "./interface/IEthStakeRegistry.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { Error } from "./utils/Error.sol";

contract EthStakingContract is Initializable, Error {
    address public serviceContract;
    address public stakeRegistry;

    event Deposit(uint256 amount);
    event Withdraw(address to, uint256 amount);

    /* ============ Initializer ============ */

    function init(
        address blast,
        address blastPoints,
        address _serviceContract,
        address pointsOperator
    )
        public
        initializer
    {
        stakeRegistry = msg.sender;
        serviceContract = _serviceContract;
        IBlast(blast).configureContract(address(this), YieldMode.AUTOMATIC, GasMode.CLAIMABLE, stakeRegistry);
        IBlastPoints(blastPoints).configurePointsOperator(pointsOperator);
    }

    /* ============ Modifier ============ */

    modifier onlyStakeRegistry() {
        if (msg.sender != stakeRegistry) {
            revert OnlyStakeRegistry();
        }
        _;
    }

    /* ============ External Functions ============ */

    function deposit() external payable onlyStakeRegistry {
        emit Deposit(msg.value);
    }

    function withdraw(address payable to, uint256 amount) external onlyStakeRegistry {
        (bool success,) = to.call{ value: amount }("");
        if (!success) {
            revert WithdrawalFailed();
        }
        emit Withdraw(to, amount);
    }
}
