// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {console} from "forge-std/Test.sol";
import {IERC20, IERC20Metadata} from "../interfaces/IERC20.sol";
import {IPool} from "../interfaces/aave-v3/IPool.sol";
import {IAaveOracle} from "../interfaces/aave-v3/IAaveOracle.sol";
import {POOL, ORACLE} from "../Constants.sol";

contract Borrow {
    IPool public constant pool = IPool(POOL);
    IAaveOracle public constant oracle = IAaveOracle(ORACLE);

    function supply(address token, uint256 amount) public {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        IERC20(token).approve(address(pool), amount);
        pool.supply({
            asset: token,
            amount: amount,
            onBehalfOf: address(this),
            referralCode: 0
        });
    }

    // Task 1 - Approximate the maximum amount of token that can be borrowed
    function approxMaxBorrow(address token) public view returns (uint256) {
        // Task 1.1 - Get asset price from the oracle.
        // The price is returned with 8 decimals (1e8 = 1 USD)

        // Task 1.2 - Get the decimals of token

        // Task 1.3 - Get the USD amount that can be borrowed from Aave V3

        // Task 1.4 - Calculate the amount of token that can be borrowed
    }

    // Task 2 - Get the health factor of this contract
    function getHealthFactor() public view returns (uint256) {}

    // Task 3 - Borrow token from Aave V3
    function borrow(address token, uint256 amount) public {}

    // Task 4 - Get variable debt balance of this contract
    function getVariableDebt(address token) public view returns (uint256) {
        // Task 4.1 - Get the variable debt token address from the pool contract

        // Task 4.2 - Get the balance of the variable debt token for this contract.
        // Balance of the variable debt token is the amount of token that this
        // contract must repay to Aave V3.
    }
}
