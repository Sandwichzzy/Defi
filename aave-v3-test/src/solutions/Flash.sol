// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {console} from "forge-std/Test.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IPool} from "../interfaces/aave-v3/IPool.sol";
import {POOL} from "../Constants.sol";

contract Flash {
    IPool public constant pool = IPool(POOL);

    function flash(address token, uint256 amount) public {
        pool.flashLoanSimple({
            receiverAddress: address(this),
            asset: token,
            amount: amount,
            params: abi.encode(msg.sender),
            referralCode: 0
        });
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 fee,
        address initiator,
        bytes calldata params
    ) public returns (bool) {
        require(msg.sender == address(pool), "not authorized");
        require(initiator == address(this), "invalid initiator");

        address caller = abi.decode(params, (address));
        IERC20(asset).transferFrom(caller, address(this), fee);

        IERC20(asset).approve(msg.sender, amount + fee);

        return true;
    }
}
