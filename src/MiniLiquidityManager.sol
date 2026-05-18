// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {
    SafeERC20
} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


interface IRouter {

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    )
        external
        returns (
            uint amountA,
            uint amountB,
            uint liquidity
        );


    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        returns (uint[] memory amounts);
}


contract MiniLiquidityManager is Ownable, ReentrancyGuard {

    using SafeERC20 for IERC20;


    error InvalidAddress();
    error InvalidAmount();
    error InvalidPath();
    error DeadlineExpired();


    IRouter public immutable router;


    event LiquidityAdded(
        address indexed user,
        address indexed tokenA,
        address indexed tokenB,
        uint amountAUsed,
        uint amountBUsed,
        uint liquidity
    );


    event SwapExecuted(
        address indexed user,
        address indexed tokenIn,
        address indexed tokenOut,
        uint amountIn,
        uint amountOut
    );


    event DustRefunded(
        address indexed user,
        address indexed token,
        uint amount
    );


    constructor(address _router)
        Ownable(msg.sender)
    {
        if (_router == address(0))
            revert InvalidAddress();

        router = IRouter(_router);
    }


    modifier ensure(uint deadline) {

        if (deadline < block.timestamp)
            revert DeadlineExpired();

        _;

    }


    function addLiquidity(
        address tokenA,
        address tokenB,

        uint amountA,
        uint amountB,

        uint amountAMin,
        uint amountBMin,

        uint deadline

    )
        external
        nonReentrant
        ensure(deadline)

    {

        if (tokenA == address(0))
            revert InvalidAddress();

        if (tokenB == address(0))
            revert InvalidAddress();

        if (amountA == 0 || amountB == 0)
            revert InvalidAmount();


        IERC20(tokenA).safeTransferFrom(
            msg.sender,
            address(this),
            amountA
        );

        IERC20(tokenB).safeTransferFrom(
            msg.sender,
            address(this),
            amountB
        );


        IERC20(tokenA).forceApprove(
            address(router),
            amountA
        );

        IERC20(tokenB).forceApprove(
            address(router),
            amountB
        );


        (
            uint usedA,
            uint usedB,
            uint liquidity

        ) = router.addLiquidity(

            tokenA,
            tokenB,

            amountA,
            amountB,

            amountAMin,
            amountBMin,

            msg.sender,
            deadline
        );


        _refundDust(
            tokenA,
            amountA - usedA
        );

        _refundDust(
            tokenB,
            amountB - usedB
        );


        emit LiquidityAdded(
            msg.sender,

            tokenA,
            tokenB,

            usedA,
            usedB,

            liquidity
        );


        IERC20(tokenA).forceApprove(
            address(router),
            0
        );

        IERC20(tokenB).forceApprove(
            address(router),
            0
        );
    }



    function swap(
        uint amountIn,
        uint amountOutMin,

        address[] calldata path,

        uint deadline

    )
        external
        nonReentrant
        ensure(deadline)

    {

        if (amountIn == 0)
            revert InvalidAmount();

        if (path.length < 2)
            revert InvalidPath();


        address tokenIn = path[0];
        address tokenOut = path[
            path.length - 1
        ];


        IERC20(tokenIn).safeTransferFrom(
            msg.sender,
            address(this),
            amountIn
        );


        IERC20(tokenIn).forceApprove(
            address(router),
            amountIn
        );


        uint[] memory amounts =
            router.swapExactTokensForTokens(

                amountIn,
                amountOutMin,

                path,

                msg.sender,

                deadline
            );


        emit SwapExecuted(
            msg.sender,

            tokenIn,
            tokenOut,

            amountIn,

            amounts[
                amounts.length - 1
            ]
        );


        IERC20(tokenIn).forceApprove(
            address(router),
            0
        );
    }



    function rescueToken(
        address token
    )
        external
        onlyOwner

    {

        uint balance =
            IERC20(token).balanceOf(
                address(this)
            );


        IERC20(token).safeTransfer(
            owner(),
            balance
        );
    }



    function _refundDust(
        address token,
        uint amount
    )
        private
    {

        if (amount == 0)
            return;


        IERC20(token).safeTransfer(
            msg.sender,
            amount
        );


        emit DustRefunded(
            msg.sender,
            token,
            amount
        );
    }
}