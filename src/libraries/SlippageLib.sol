// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library SlippageLib {
    uint256 internal constant BPS = 10_000;

    error InvalidBps();

    function calculateMinAmount(
        uint256 amount,
        uint256 slippageBps
    )
        internal
        pure
        returns (uint256)
    {
        if (slippageBps > BPS) {
            revert InvalidBps();
        }

        return (amount * (BPS - slippageBps)) / BPS;
    }
}