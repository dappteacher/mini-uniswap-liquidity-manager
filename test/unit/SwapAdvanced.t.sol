// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

contract SwapAdvancedTest is Test {
    function testSlippageMath() public pure{
        uint256 amount = 1000 ether;

        uint256 minOut =
            amount - ((amount * 300) / 10_000);

        assertEq(minOut, 970 ether);
    }
}