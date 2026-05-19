// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    IUniswapV2Router02
} from "../interfaces/IUniswapV2Router02.sol";

contract QuoteManager {
    IUniswapV2Router02 public immutable router;

    constructor(address _router) {
        router = IUniswapV2Router02(_router);
    }

    function quoteOut(
        uint256 amountIn,
        address[] calldata path
    )
        external
        view
        returns (uint256 amountOut)
    {
        uint256[] memory amounts =
            router.getAmountsOut(amountIn, path);

        return amounts[amounts.length - 1];
    }

    function quoteIn(
        uint256 amountOut,
        address[] calldata path
    )
        external
        view
        returns (uint256 amountIn)
    {
        uint256[] memory amounts =
            router.getAmountsIn(amountOut, path);

        return amounts[0];
    }
}