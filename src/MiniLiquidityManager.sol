// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {
    SafeERC20
} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {
    IRouter
} from "./interfaces/IRouter.sol";

contract MiniLiquidityManager is
    Ownable,
    Pausable,
    ReentrancyGuard
{
    using SafeERC20 for IERC20;

    // =============================================================
    //                           ERRORS
    // =============================================================

    error InvalidAddress();
    error InvalidAmount();
    error InvalidPath();
    error DeadlineExpired();
    error SameToken();

    // =============================================================
    //                           STORAGE
    // =============================================================

    IRouter public immutable router;

    mapping(address => uint256) public totalLiquidityActions;
    mapping(address => uint256) public totalSwapActions;

    // =============================================================
    //                           EVENTS
    // =============================================================

    event LiquidityAdded(
        address indexed user,
        address indexed tokenA,
        address indexed tokenB,
        uint256 amountAUsed,
        uint256 amountBUsed,
        uint256 liquidity
    );

    event SwapExecuted(
        address indexed user,
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    event DustRefunded(
        address indexed user,
        address indexed token,
        uint256 amount
    );

    event EmergencyWithdraw(
        address indexed token,
        uint256 amount
    );

    // =============================================================
    //                         CONSTRUCTOR
    // =============================================================

    constructor(address _router)
        Ownable(msg.sender)
    {
        if (_router == address(0)) {
            revert InvalidAddress();
        }

        router = IRouter(_router);
    }

    // =============================================================
    //                         MODIFIERS
    // =============================================================

    modifier ensure(uint256 deadline) {
        if (deadline < block.timestamp) {
            revert DeadlineExpired();
        }

        _;
    }

    // =============================================================
    //                    LIQUIDITY MANAGEMENT
    // =============================================================

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    )
        external
        nonReentrant
        whenNotPaused
        ensure(deadline)
    {
        if (tokenA == address(0) || tokenB == address(0)) {
            revert InvalidAddress();
        }

        if (tokenA == tokenB) {
            revert SameToken();
        }

        if (amountA == 0 || amountB == 0) {
            revert InvalidAmount();
        }

        IERC20(tokenA).safeTransferFrom(
            msg.sender,
            address(this),
            amountA
        );

        IERC20(tokenB).safeTransferFrom(
            msg.sender,
            address(this),
            amountB
        );

        IERC20(tokenA).forceApprove(
            address(router),
            amountA
        );

        IERC20(tokenB).forceApprove(
            address(router),
            amountB
        );

        (
            uint256 usedA,
            uint256 usedB,
            uint256 liquidity
        ) = router.addLiquidity(
            tokenA,
            tokenB,
            amountA,
            amountB,
            amountAMin,
            amountBMin,
            msg.sender,
            deadline
        );

        _refundDust(tokenA, amountA - usedA);
        _refundDust(tokenB, amountB - usedB);

        unchecked {
            totalLiquidityActions[msg.sender]++;
        }

        emit LiquidityAdded(
            msg.sender,
            tokenA,
            tokenB,
            usedA,
            usedB,
            liquidity
        );

        IERC20(tokenA).forceApprove(address(router), 0);
        IERC20(tokenB).forceApprove(address(router), 0);
    }

    // =============================================================
    //                             SWAP
    // =============================================================

    function swap(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadline
    )
        external
        nonReentrant
        whenNotPaused
        ensure(deadline)
    {
        if (amountIn == 0) {
            revert InvalidAmount();
        }

        if (path.length < 2) {
            revert InvalidPath();
        }

        address tokenIn = path[0];
        address tokenOut = path[path.length - 1];

        IERC20(tokenIn).safeTransferFrom(
            msg.sender,
            address(this),
            amountIn
        );

        IERC20(tokenIn).forceApprove(
            address(router),
            amountIn
        );

        uint256[] memory amounts =
            router.swapExactTokensForTokens(
                amountIn,
                amountOutMin,
                path,
                msg.sender,
                deadline
            );

        unchecked {
            totalSwapActions[msg.sender]++;
        }

        emit SwapExecuted(
            msg.sender,
            tokenIn,
            tokenOut,
            amountIn,
            amounts[amounts.length - 1]
        );

        IERC20(tokenIn).forceApprove(address(router), 0);
    }

    // =============================================================
    //                         ADMIN ACTIONS
    // =============================================================

    function pause()
        external
        onlyOwner
    {
        _pause();
    }

    function unpause()
        external
        onlyOwner
    {
        _unpause();
    }

    function rescueToken(
        address token,
        uint256 amount
    )
        external
        onlyOwner
    {
        IERC20(token).safeTransfer(owner(), amount);

        emit EmergencyWithdraw(token, amount);
    }

    // =============================================================
    //                         INTERNAL LOGIC
    // =============================================================

    function _refundDust(
        address token,
        uint256 amount
    )
        internal
    {
        if (amount == 0) {
            return;
        }

        IERC20(token).safeTransfer(msg.sender, amount);

        emit DustRefunded(
            msg.sender,
            token,
            amount
        );
    }
}