// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {console} from "forge-std/Test.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IPool} from "../interfaces/aave-v3/IPool.sol";
import {POOL} from "../Constants.sol";

contract Supply {
    IPool public constant pool = IPool(POOL);

    // Task 1 - Supply token to Aave V3 pool
    function supply(address token, uint256 amount) public {
        // Task 1.1 - Transfer token from msg.sender
        IERC20(token).transferFrom(msg.sender,address(this),amount);
        // Task 1.2 - Approve the pool contract to spend token
        IERC20(token).approve(address(pool),amount);
        // Task 1.3 - Supply token to the pool
        pool.supply({
             asset:token,
             amount:amount,
             onBehalfOf:address(this),
             referralCode:0
        });
    }

    // Task 2 - Get supply balance
    function getSupplyBalance(address token) public view returns (uint256) {
        // Balance of the token that can be withdrawn is the balance of aToken
        // Task 2.1 - Get the aToken address
        IPool.ReserveData memory reserve =pool.getReserveData(token);
        // Task 2.2 - Get the balance of aToken for this contract
        return IERC20(reserve.aTokenAddress).balanceOf(address(this));
    }
}
