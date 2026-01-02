// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {POOL, WETH, DAI} from "../src/Constants.sol";
import {IPool} from "../src/interfaces/aave-v3/IPool.sol";
import {Flash} from "@exercises/Flash.sol";

contract FlashTest is Test {
    IERC20 private constant dai = IERC20(DAI);
    IPool private constant pool = IPool(POOL);
    Flash private target;

    function setUp() public {
        deal(DAI, address(this), 1000 * 1e18);
        target = new Flash();

        dai.approve(address(target), 1000 * 1e18);
    }

    function test_flash() public {
        vm.expectCall(
            address(pool),
            abi.encodeCall(
                pool.flashLoanSimple,
                (address(target), DAI, 1e6 * 1e18, abi.encode(address(this)), 0)
            )
        );
        target.flash(DAI, 1e6 * 1e18);
    }
}
