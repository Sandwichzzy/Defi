// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ISwapRouter} from "../interfaces/uniswap-v3/ISwapRouter.sol";
import {UNISWAP_V3_SWAP_ROUTER_02} from "../Constants.sol";

abstract contract Swap {
    ISwapRouter public constant router = ISwapRouter(UNISWAP_V3_SWAP_ROUTER_02);

    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address receiver,
        bytes memory data
    ) public returns (uint256 amountOut) {
        uint24 fee = abi.decode(data, (uint24));
        return router.exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: fee,
                recipient: receiver,
                amountIn: amountIn,
                amountOutMinimum: amountOutMin,
                sqrtPriceLimitX96: 0
            })
        );
    }
}
