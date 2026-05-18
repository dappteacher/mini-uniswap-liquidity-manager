// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import "../../src/mocks/MockUniswapRouter.sol";
import "../../src/mocks/MockUSDC.sol";
import "../../src/mocks/MockWETH.sol";


contract MockRouterTest is Test {

    MockUniswapRouter router;

    MockUSDC usdc;
    MockWETH weth;


    uint256 constant INITIAL_USDC_LIQUIDITY =
        1_000_000e6;

    uint256 constant INITIAL_WETH_LIQUIDITY =
        100 ether;

    uint256 constant SWAP_AMOUNT =
        1000e6;


    function setUp() public {

        router = new MockUniswapRouter();

        usdc = new MockUSDC();
        weth = new MockWETH();


        // mint enough for:
        // 1) pool liquidity
        // 2) trader swap
        usdc.mint(
            address(this),
            INITIAL_USDC_LIQUIDITY + SWAP_AMOUNT
        );

        weth.mint(
            address(this),
            1000 ether
        );


        usdc.approve(
            address(router),
            type(uint256).max
        );

        weth.approve(
            address(router),
            type(uint256).max
        );


        // seed liquidity
        router.addLiquidity(
            address(usdc),
            address(weth),
            INITIAL_USDC_LIQUIDITY,
            INITIAL_WETH_LIQUIDITY,
            0,
            0,
            address(this),
            block.timestamp
        );
    }



    function testSwap() public {

        address[] memory path =
            new address[](2);

        path[0] = address(usdc);
        path[1] = address(weth);


        uint[] memory amounts =
            router.swapExactTokensForTokens(
                SWAP_AMOUNT,
                0,
                path,
                address(this),
                block.timestamp
            );


        assertEq(
            amounts.length,
            2
        );

        assertEq(
            amounts[0],
            SWAP_AMOUNT
        );

        assertGt(
            amounts[1],
            0
        );


        assertEq(
            router.reserves(
                address(usdc)
            ),
            INITIAL_USDC_LIQUIDITY
                + SWAP_AMOUNT
        );
    }



    function testRevertWithoutLiquidity()
        public
    {

        MockUniswapRouter emptyRouter =
            new MockUniswapRouter();


        address[] memory path =
            new address[](2);

        path[0] = address(usdc);
        path[1] = address(weth);


        vm.expectRevert(
            MockUniswapRouter
                .InsufficientLiquidity
                .selector
        );


        emptyRouter.swapExactTokensForTokens(
            SWAP_AMOUNT,
            0,
            path,
            address(this),
            block.timestamp
        );
    }



    function testRevertInvalidPath()
        public
    {

        address[] memory path =
            new address[](1);

        path[0] = address(usdc);


        vm.expectRevert(
            MockUniswapRouter
                .InvalidPath
                .selector
        );


        router.swapExactTokensForTokens(
            SWAP_AMOUNT,
            0,
            path,
            address(this),
            block.timestamp
        );
    }



    function testRevertZeroAmount()
        public
    {

        address[] memory path =
            new address[](2);

        path[0] = address(usdc);
        path[1] = address(weth);


        vm.expectRevert(
            MockUniswapRouter
                .InvalidAmount
                .selector
        );


        router.swapExactTokensForTokens(
            0,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}