// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC20} from "../interfaces/IERC20.sol";
import {IPool} from "../interfaces/aave-v3/IPool.sol";
import {POOL} from "../Constants.sol";

abstract contract Aave {
    IPool public constant pool = IPool(POOL);

    function supply(address token, uint256 amount, address onBehalfOf) public {
        pool.supply({
            asset: token,
            amount: amount,
            onBehalfOf: onBehalfOf,
            referralCode: 0
        });
    }

    function borrow(address token, uint256 amount, address onBehalfOf) public {
        pool.borrow({
            asset: token,
            amount: amount,
            // 1 = Stable interest rate
            // 2 = Variable interest rate
            interestRateMode: 2,
            referralCode: 0,
            onBehalfOf: onBehalfOf
        });
    }

    function repay(address token, uint256 amount, address onBehalfOf)
        public
        returns (uint256 repaid)
    {
        return pool.repay({
            asset: token,
            amount: amount,
            interestRateMode: 2,
            onBehalfOf: onBehalfOf
        });
    }

    function withdraw(address token, uint256 amount, address to)
        public
        returns (uint256 withdrawn)
    {
        return pool.withdraw({asset: token, amount: amount, to: to});
    }

    function getHealthFactor(address user) public view returns (uint256) {
        (,,,,, uint256 healthFactor) = pool.getUserAccountData(user);
        return healthFactor;
    }

    function getVariableDebtTokenAddress(address token)
        public
        view
        returns (address)
    {
        IPool.ReserveData memory reserve = pool.getReserveData(token);
        return reserve.variableDebtTokenAddress;
    }

    function getVariableDebt(address token, address user)
        public
        view
        returns (uint256)
    {
        IPool.ReserveData memory reserve = pool.getReserveData(token);
        return IERC20(reserve.variableDebtTokenAddress).balanceOf(user);
    }

    function getATokenAddress(address token) public view returns (address) {
        IPool.ReserveData memory reserve = pool.getReserveData(token);
        return reserve.aTokenAddress;
    }

    function getATokenBalance(address token, address user)
        public
        view
        returns (uint256)
    {
        IPool.ReserveData memory reserve = pool.getReserveData(token);
        return IERC20(reserve.aTokenAddress).balanceOf(user);
    }
}
