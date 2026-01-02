// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IVariableDebtToken {
    function balanceOf(address user) external view returns (uint256);
    function borrowAllowance(address fromUser, address toUser)
        external
        view
        returns (uint256);
    function approveDelegation(address delegatee, uint256 amount) external;
}
