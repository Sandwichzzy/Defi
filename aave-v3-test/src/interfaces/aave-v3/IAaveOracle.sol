// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IAaveOracle {
    // Returns USD price (1 USD = 1e8)
    function getAssetPrice(address asset) external view returns (uint256);
}
