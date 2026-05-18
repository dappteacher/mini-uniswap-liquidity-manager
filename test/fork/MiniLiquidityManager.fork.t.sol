// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";


contract MiniLiquidityForkTest is Test {

    bool forkEnabled;


    function setUp()
        public
    {

        string memory rpc =
            vm.envOr(
                "MAINNET_RPC_URL",
                string("")
            );


        if (
            bytes(rpc).length == 0
        ) {

            forkEnabled = false;

            return;
        }


        forkEnabled = true;


        vm.createSelectFork(
            rpc
        );
    }


    function test_ForkBlock()
        public
        view
    {

        if (
            !forkEnabled
        ) {
            return;
        }


        assertGt(
            block.number,
            0
        );
    }
}