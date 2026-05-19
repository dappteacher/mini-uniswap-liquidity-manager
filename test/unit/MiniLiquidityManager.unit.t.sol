// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {MiniLiquidityManager} from "../../src/MiniLiquidityManager.sol";

import {ERC20Mock} from "../../src/mocks/ERC20Mock.sol";

import {RouterMock} from "../../src/mocks/RouterMock.sol";

contract MiniLiquidityManagerUnitTest is Test {
    MiniLiquidityManager manager;

    ERC20Mock tokenA;
    ERC20Mock tokenB;

    RouterMock router;

    address alice = address(1);

    function setUp() public {
        router = new RouterMock();

        manager = new MiniLiquidityManager(address(router));

        tokenA = new ERC20Mock();

        tokenB = new ERC20Mock();

        tokenA.mint(alice, 1_000 ether);

        tokenB.mint(alice, 1_000 ether);

        vm.startPrank(alice);

        tokenA.approve(address(manager), type(uint).max);

        tokenB.approve(address(manager), type(uint).max);

        vm.stopPrank();
    }

    function test_AddLiquidity() public {
        vm.startPrank(alice);

        manager.addLiquidity(
            address(tokenA),
            address(tokenB),
            100 ether,
            100 ether,
            0,
            0,
            block.timestamp + 1
        );

        vm.stopPrank();
    }

    function test_Swap() public {
        address[] memory path = new address[](2);

        path[0] = address(tokenA);

        path[1] = address(tokenB);

        vm.startPrank(alice);

        manager.swapExactInput(
            100 ether,
            95 ether,
            300,
            path,
            block.timestamp + 1 hours
        );

        vm.stopPrank();
    }

    function test_RevertZeroAmount() public {
        vm.startPrank(alice);

        vm.expectRevert();

        manager.addLiquidity(
            address(tokenA),
            address(tokenB),
            0,
            100 ether,
            0,
            0,
            block.timestamp + 1
        );

        vm.stopPrank();
    }

    function test_RevertExpiredDeadline() public {
        vm.startPrank(alice);

        vm.expectRevert();

        manager.addLiquidity(
            address(tokenA),
            address(tokenB),
            100 ether,
            100 ether,
            0,
            0,
            block.timestamp - 1
        );

        vm.stopPrank();
    }
}
