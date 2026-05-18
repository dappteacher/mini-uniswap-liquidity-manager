// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from
    "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {SafeERC20} from
    "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract MockUniswapRouter {

    using SafeERC20 for IERC20;


    error SlippageExceeded();
    error InvalidPath();
    error InvalidAmount();
    error InsufficientLiquidity();


    mapping(address => uint256) public reserves;


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address,
        uint
    )
        external
        returns (
            uint amountA,
            uint amountB,
            uint liquidity
        )
    {

        if (
            amountADesired < amountAMin ||
            amountBDesired < amountBMin
        ) {
            revert SlippageExceeded();
        }


        IERC20(tokenA).safeTransferFrom(
            msg.sender,
            address(this),
            amountADesired
        );

        IERC20(tokenB).safeTransferFrom(
            msg.sender,
            address(this),
            amountBDesired
        );


        reserves[tokenA] += amountADesired;
        reserves[tokenB] += amountBDesired;


        amountA = amountADesired;
        amountB = amountBDesired;

        liquidity =
            amountADesired < amountBDesired
                ? amountADesired
                : amountBDesired;
    }



    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint
    )
        external
        returns (
            uint[] memory amounts
        )
    {

        if (path.length < 2)
            revert InvalidPath();

        if (amountIn == 0)
            revert InvalidAmount();


        address tokenIn = path[0];
        address tokenOut = path[1];


        uint amountOut =
            (amountIn * 997) / 1000;


        if (
            reserves[tokenOut] < amountOut
        ) {
            revert InsufficientLiquidity();
        }


        if (
            amountOut < amountOutMin
        ) {
            revert SlippageExceeded();
        }


        IERC20(tokenIn).safeTransferFrom(
            msg.sender,
            address(this),
            amountIn
        );


        IERC20(tokenOut).safeTransfer(
            to,
            amountOut
        );


        reserves[tokenIn] += amountIn;
        reserves[tokenOut] -= amountOut;


        amounts = new uint[](2);

        amounts[0] = amountIn;
        amounts[1] = amountOut;
    }
}