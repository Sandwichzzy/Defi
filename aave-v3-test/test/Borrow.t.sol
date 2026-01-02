// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {POOL, ORACLE, WETH, DAI} from "../src/Constants.sol";
import {IPool} from "../src/interfaces/aave-v3/IPool.sol";
import {IAaveOracle} from "../src/interfaces/aave-v3/IAaveOracle.sol";
import {Borrow} from "@exercises/Borrow.sol";

contract BorrowTest is Test {
    IERC20 private constant weth = IERC20(WETH);
    IERC20 private constant dai = IERC20(DAI);
    IPool private constant pool = IPool(POOL);
    IAaveOracle private constant oracle = IAaveOracle(ORACLE);
    IERC20 private debtToken;
    Borrow private target;

    function setUp() public {
        IPool.ReserveData memory reserve = pool.getReserveData(DAI);
        debtToken = IERC20(reserve.variableDebtTokenAddress);

        deal(WETH, address(this), 1e18);
        target = new Borrow();

        weth.approve(address(target), 1e18);
        target.supply(WETH, 1e18);
    }

    function test_borrow() public {
        uint256 wethPrice = oracle.getAssetPrice(WETH);
        uint256 approxMaxBorrow = target.approxMaxBorrow(DAI);
        uint256 hf = target.getHealthFactor();

        console.log("WETH price: %e", wethPrice);
        console.log("Approximate max borrow: %e", approxMaxBorrow);
        console.log("Health factor: %e", hf);

        assertGt(hf, 0, "Health factor");
        assertGt(approxMaxBorrow, 0, "Approximate max borrow");
        assertEq(target.getVariableDebt(DAI), 0, "Variable debt before borrow");

        target.borrow(DAI, 100 * 1e18);

        uint256 bal = dai.balanceOf(address(target));
        uint256 debt = debtToken.balanceOf(address(target));

        console.log("DAI balance: %e", bal);
        console.log("DAI debt: %e", debt);

        assertEq(bal, 100 * 1e18, "DAI balance");
        assertGe(debt, bal, "Debt");
        assertEq(
            target.getVariableDebt(DAI), debt, "Variable debt after borrow"
        );
    }
}
