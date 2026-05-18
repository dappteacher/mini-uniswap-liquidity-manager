// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {
    MiniLiquidityManager
} from "../../src/MiniLiquidityManager.sol";

import {
    ERC20Mock
} from "../../src/mocks/ERC20Mock.sol";

import {
    RouterMock
} from "../../src/mocks/RouterMock.sol";


contract MiniLiquidityManagerFuzzTest is Test {

    MiniLiquidityManager manager;

    ERC20Mock tokenA;
    ERC20Mock tokenB;

    address alice =
        address(1);


    function setUp()
        public
    {

        RouterMock router =
            new RouterMock();

        manager =
            new MiniLiquidityManager(
                address(router)
            );


        tokenA =
            new ERC20Mock();

        tokenB =
            new ERC20Mock();


        tokenA.mint(
            alice,
            type(uint128).max
        );

        tokenB.mint(
            alice,
            type(uint128).max
        );
    }


    function testFuzz_AddLiquidity(

        uint amountA,
        uint amountB

    )
        public
    {

        amountA =
            bound(
                amountA,
                1,
                1000 ether
            );

        amountB =
            bound(
                amountB,
                1,
                1000 ether
            );


        vm.startPrank(
            alice
        );


        tokenA.approve(
            address(manager),
            type(uint).max
        );

        tokenB.approve(
            address(manager),
            type(uint).max
        );


        manager.addLiquidity(

            address(tokenA),
            address(tokenB),

            amountA,
            amountB,

            0,
            0,

            block.timestamp + 1
        );


        vm.stopPrank();
    }
}