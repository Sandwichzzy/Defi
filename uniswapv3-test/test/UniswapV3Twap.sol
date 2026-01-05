// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {TickMath} from "../src/uniswap-v3/TickMath.sol";
import {FullMath} from "../src/uniswap-v3/FullMath.sol";
import {IUniswapV3Pool} from "../src/interfaces/uniswap-v3/IUniswapV3Pool.sol";

error InvalidToken();

contract UniswapV3Twap {
    IUniswapV3Pool public immutable pool;
    address public immutable token0;
    address public immutable token1;

    constructor(address _pool) {
        pool = IUniswapV3Pool(_pool);
        token0 = pool.token0();
        token1 = pool.token1();
    }

    // Copied from
    // https://github.com/Uniswap/v3-periphery/blob/0.8/contracts/libraries/OracleLibrary.sol
    /// @notice Given a tick and a token amount, calculates the amount of token received in exchange
    function getQuoteAtTick(
        int24 tick,
        uint128 baseAmount,
        address baseToken,
        address quoteToken
    ) internal pure returns (uint256 quoteAmount) {
        uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(tick);

        // Calculate quoteAmount with better precision if it doesn't overflow when multiplied by itself
        if (sqrtRatioX96 <= type(uint128).max) {
            uint256 ratioX192 = uint256(sqrtRatioX96) * sqrtRatioX96;
            quoteAmount = baseToken < quoteToken
                // 相当于：baseAmount * price
                ? FullMath.mulDiv(ratioX192, baseAmount, 1 << 192)
                //相当于：baseAmount / price
                : FullMath.mulDiv(1 << 192, baseAmount, ratioX192);
        } else {
            //ratioX128 = price × 2^128
            uint256 ratioX128 =
                FullMath.mulDiv(sqrtRatioX96, sqrtRatioX96, 1 << 64);
            quoteAmount = baseToken < quoteToken
                ? FullMath.mulDiv(ratioX128, baseAmount, 1 << 128)
                : FullMath.mulDiv(1 << 128, baseAmount, ratioX128);
        }
    }

    function getTwapAmountOut(address tokenIn, uint128 amountIn, uint32 dt)
        external
        view
        returns (uint256 amountOut)
    {
        // Task 1 - Require tokenIn is token0 or token1
        if (tokenIn != token0 && tokenIn != token1) {
            revert InvalidToken();
        }
        // Task 2 - Assign tokenOut
        address tokenOut = tokenIn == token0 ? token1 : token0;

        // Task 3 - Fill out timeDeltas with dt and 0
        //创建两个时间点：timeDeltas[0] = dt: 表示从现在回溯dt秒的时刻, timeDeltas[1] = 0: 表示当前时刻（0秒前）
        uint32[] memory timeDeltas = new uint32[](2);
        timeDeltas[0] = dt;
        timeDeltas[1] = 0;

        // Task 4 - Call pool.observe
        // NOTE int56 since tick * time = int24 * uint32
        // 调用Uniswap V3池子的observe方法, 返回两个时间点的累积tick值（tickCumulative）
        // tickCumulative = 每秒的tick值累加，用于计算TWAP
        (int56[] memory tickCumulatives,) = pool.observe(timeDeltas);
        // Task 5 - Calculate tickCumulativeDelta
        int56 tickCumulativeDelta = tickCumulatives[1] - tickCumulatives[0];

        // Task 6 - Calculate average tick
        // 平均tick = tick累积变化量 ÷ 时间间隔
        int24 tick = int24(tickCumulativeDelta / int56(uint56(dt)));

        // Always round to negative infinity
        //关键细节：Solidity的整数除法默认向0取整
        // 对于负数除法，例如-3/2，Solidity会得到-1，但TWAP计算需要向下取整得到-2
        // 如果tick累积差值为负且不能整除，需要将tick减1以实现向下取整
        if (
            tickCumulativeDelta < 0
                && (tickCumulativeDelta % int56(uint56(dt)) != 0)
        ) {
            tick--;
        }

        // Task 7 - Call getQuoteAtTick
        // 基于TWAP价格计算输出代币数量
        return getQuoteAtTick(tick, amountIn, tokenIn, tokenOut);
    }
}
