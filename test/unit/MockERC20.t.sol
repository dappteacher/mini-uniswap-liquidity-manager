// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import "../../src/mocks/MockUSDC.sol";
import "../../src/mocks/MockWETH.sol";

contract MockERC20Test is Test {
    MockUSDC usdc;
    MockWETH weth;

    address alice = address(1);

    function setUp() public {
        usdc = new MockUSDC();
        weth = new MockWETH();
    }

    function testUSDCMint() public {
        uint256 amount = 1000 * 1e6;

        usdc.mint(alice, amount);

        assertEq(usdc.balanceOf(alice), amount);
    }

    function testWETHMint() public {
        uint256 amount = 5 ether;

        weth.mint(alice, amount);

        assertEq(weth.balanceOf(alice), amount);
    }

    function testUSDCDecimals() public view{
        assertEq(usdc.decimals(), 6);
    }

    function testWETHDecimals() public view{
        assertEq(weth.decimals(), 18);
    }
}