// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


contract RouterMock {


    function addLiquidity(

        address,
        address,

        uint amountADesired,
        uint amountBDesired,

        uint,
        uint,

        address,
        uint

    )
        external
        pure

        returns (

            uint amountA,
            uint amountB,
            uint liquidity
        )

    {

        /*
            Simulate:

            90% usage
            10% dust refund
        */

        amountA =
            amountADesired * 90 / 100;

        amountB =
            amountBDesired * 90 / 100;


        liquidity =
            (
                amountA +
                amountB
            ) / 2;
    }



    function swapExactTokensForTokens(

        uint amountIn,
        uint,

        address[] calldata path,

        address,
        uint

    )
        external
        pure

        returns (
            uint[] memory amounts
        )

    {

        amounts =
            new uint[](
                path.length
            );


        amounts[0] =
            amountIn;


        /*
            Simulate 1:1 swap
        */

        amounts[
            path.length - 1
        ] = amountIn;
    }
}