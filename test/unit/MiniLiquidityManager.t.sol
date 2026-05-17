// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/MiniLiquidityManager.sol";

contract MiniLiquidityManagerTest is Test {
    MiniLiquidityManager manager;

    function setUp() public {
        manager = new MiniLiquidityManager();
    }

    function testDeployment() public view{
        assertTrue(address(manager) != address(0));
    }
}