// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "forge-std/StdInvariant.sol";

import {
    MiniLiquidityManager
} from "../../src/MiniLiquidityManager.sol";

import {
    ERC20Mock
} from "../../src/mocks/ERC20Mock.sol";

import {
    RouterMock
} from "../../src/mocks/RouterMock.sol";


contract Handler is Test {

    MiniLiquidityManager manager;

    ERC20Mock tokenA;
    ERC20Mock tokenB;

    address user =
        address(1);


    constructor(
        MiniLiquidityManager _manager,
        ERC20Mock _tokenA,
        ERC20Mock _tokenB
    )
    {
        manager = _manager;

        tokenA = _tokenA;
        tokenB = _tokenB;


        tokenA.mint(
            user,
            type(uint128).max
        );

        tokenB.mint(
            user,
            type(uint128).max
        );


        vm.startPrank(user);

        tokenA.approve(
            address(manager),
            type(uint).max
        );

        tokenB.approve(
            address(manager),
            type(uint).max
        );

        vm.stopPrank();
    }


    function addLiquidity(

        uint amountA,
        uint amountB

    )
        external
    {

        amountA =
            bound(
                amountA,
                1,
                100 ether
            );

        amountB =
            bound(
                amountB,
                1,
                100 ether
            );


        vm.prank(user);

        manager.addLiquidity(

            address(tokenA),
            address(tokenB),

            amountA,
            amountB,

            0,
            0,

            block.timestamp + 1
        );
    }
}



contract MiniLiquidityInvariantTest
    is StdInvariant, Test
{

    MiniLiquidityManager manager;

    Handler handler;


    function setUp()
        public
    {

        RouterMock router =
            new RouterMock();

        ERC20Mock tokenA =
            new ERC20Mock();

        ERC20Mock tokenB =
            new ERC20Mock();


        manager =
            new MiniLiquidityManager(
                address(router)
            );


        handler =
            new Handler(
                manager,
                tokenA,
                tokenB
            );


        targetContract(
            address(handler)
        );
    }


    function invariant_NoEth()
        public
        view
    {
        assertEq(
            address(manager).balance,
            0
        );
    }
}