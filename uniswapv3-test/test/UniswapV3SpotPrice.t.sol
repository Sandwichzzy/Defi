pragma solidity 0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {IUniswapV3Pool} from "../src/interfaces/uniswap-v3/IUniswapV3Pool.sol";
import {UNISWAP_V3_POOL_USDC_WETH_500} from "../src/Constants.sol";
import {FullMath} from "../src/uniswap-v3/FullMath.sol";

contract UniswapV3SwapTest is Test {
    // token0 (X)
    uint256 private constant USDC_DECIMALS = 1e6;
    // token1 (Y)
    uint256 private constant WETH_DECIMALS = 1e18;
    // 1 << 96 = 2 ** 96
    uint256 private constant Q96 = 1 << 96;
    IUniswapV3Pool private immutable pool =
        IUniswapV3Pool(UNISWAP_V3_POOL_USDC_WETH_500);

    // Exercise 1
    // - Get price of WETH in terms of USDC and return price with 18 decimals
    function test_spot_price_from_sqrtPriceX96() public {
        uint256 price = 0;
        IUniswapV3Pool.Slot0 memory slot0 = pool.slot0();

        // Write your code here
        // Don’t change any other code

        // P     = Y / X = WETH / USDC
        //               = price of USDC in terms of WETH
        // 1 / P = X / Y = USDC / WETH
        //               = price of WETH in terms of USDC

        // P has 1e18 / 1e6 = 1e12 decimals
        // 1 / P has 1e6 / 1e18 = 1e-12 decimals

        // sqrtPriceX96 * sqrtPriceX96 might overflow
        // So use FullMath.mulDiv to do uint256 * uint256 / uint256 without overflow

        // sqrtPriceX96 = sqrt(P) * Q96
        // sqrt(P) * Q96 * sqrt(P) * Q96
        //            96 bits         96 bits = 192 bits
        // 256 bits - 192 bits = 64 bits
        // 2**64 / 1e18 approx = 18

        // price = sqrt(P) * Q96 * sqrt(P) * Q96 / Q96
        price = FullMath.mulDiv(slot0.sqrtPriceX96, slot0.sqrtPriceX96, Q96);
        // 1 / price = 1 / (P * Q96)
        price = 1e12 * 1e18 * Q96 / price;

        assertGt(price, 0, "price = 0");
        console2.log("price %e", price);
    }
}
