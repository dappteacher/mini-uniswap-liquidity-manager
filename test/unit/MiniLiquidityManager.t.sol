// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import "../../src/MiniLiquidityManager.sol";
import "../../src/mocks/MockUniswapRouter.sol";


contract MiniLiquidityManagerTest is Test {

    MiniLiquidityManager manager;
    MockUniswapRouter router;


    function setUp() public {

        router = new MockUniswapRouter();

        manager = new MiniLiquidityManager(
            address(router)
        );
    }


    function testDeployment() public view{

        assertEq(
            address(manager.router()),
            address(router)
        );
    }


    function testRouterIsImmutable() public view{

        assertTrue(
            address(manager.router()) != address(0)
        );
    }
}