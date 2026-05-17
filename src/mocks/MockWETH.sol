// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./MockERC20.sol";

contract MockWETH is MockERC20 {
    constructor() MockERC20("Mock Wrapped Ether", "mWETH", 18) {}
}