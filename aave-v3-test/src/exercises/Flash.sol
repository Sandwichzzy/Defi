// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {console} from "forge-std/Test.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IPool} from "../interfaces/aave-v3/IPool.sol";
import {POOL} from "../Constants.sol";

contract Flash {
    IPool public constant pool = IPool(POOL);

    // Task 1 - Initiate flash loan
    function flash(address token, uint256 amount) public {}

    // Task 2 - Repay flash loan
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 fee,
        address initiator,
        bytes calldata params
    ) public returns (bool) {
        // Task 2.1 - Check that msg.sender is the pool contract

        // Task 2.2 - Check that initiator is this contract

        // Task 2.3 - Decode caller from params and transfer
        // flash loan fee from this caller

        // Task 2.4 - Approve the pool to spend flash loaned amount + fee

        // Task 2.5 - Return true
    }
}
