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

import {
    IERC20Permit
} from "./interfaces/IERC20Permit.sol";

import {
    SlippageLib
} from "./libraries/SlippageLib.sol";

contract MiniLiquidityManager is
    Ownable,
    Pausable,
    ReentrancyGuard
{
    using SafeERC20 for IERC20;

    // =============================================================
    //                           CONSTANTS
    // =============================================================

    uint256 public constant MAX_SLIPPAGE_BPS = 500;

    // =============================================================
    //                            ERRORS
    // =============================================================

    error InvalidAddress();
    error InvalidAmount();
    error InvalidPath();
    error SameToken();
    error SlippageTooHigh();
    error DeadlineExpired();

    // =============================================================
    //                           STORAGE
    // =============================================================

    IRouter public immutable router;

    mapping(address => uint256) public totalVolumeIn;
    mapping(address => uint256) public totalSwaps;
    mapping(address => uint256) public totalLiquidityActions;

    // =============================================================
    //                            EVENTS
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

    event PermitUsed(
        address indexed owner,
        uint256 amount
    );

    // =============================================================
    //                          CONSTRUCTOR
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
    //                           MODIFIERS
    // =============================================================

    modifier ensure(uint256 deadline) {
        if (deadline < block.timestamp) {
            revert DeadlineExpired();
        }

        _;
    }

    // =============================================================
    //                     LIQUIDITY MANAGEMENT
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

        if (amountA > usedA) {
            uint256 refundA = amountA - usedA;

            IERC20(tokenA).safeTransfer(
                msg.sender,
                refundA
            );

            emit DustRefunded(
                msg.sender,
                tokenA,
                refundA
            );
        }

        if (amountB > usedB) {
            uint256 refundB = amountB - usedB;

            IERC20(tokenB).safeTransfer(
                msg.sender,
                refundB
            );

            emit DustRefunded(
                msg.sender,
                tokenB,
                refundB
            );
        }

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

    function swapExactInput(
        uint256 amountIn,
        uint256 expectedAmountOut,
        uint256 slippageBps,
        address[] calldata path,
        uint256 deadline
    )
        external
        nonReentrant
        whenNotPaused
        ensure(deadline)
        returns (uint256 amountOut)
    {
        if (amountIn == 0) {
            revert InvalidAmount();
        }

        if (path.length < 2) {
            revert InvalidPath();
        }

        if (slippageBps > MAX_SLIPPAGE_BPS) {
            revert SlippageTooHigh();
        }

        uint256 minOut =
            SlippageLib.calculateMinAmount(
                expectedAmountOut,
                slippageBps
            );

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
                minOut,
                path,
                msg.sender,
                deadline
            );

        amountOut = amounts[amounts.length - 1];

        unchecked {
            totalVolumeIn[msg.sender] += amountIn;
            totalSwaps[msg.sender]++;
        }

        emit SwapExecuted(
            msg.sender,
            tokenIn,
            tokenOut,
            amountIn,
            amountOut
        );

        IERC20(tokenIn).forceApprove(address(router), 0);
    }

    // =============================================================
    //                       PERMIT + SWAP
    // =============================================================

    function permitAndSwap(
        address token,
        uint256 amount,
        uint256 permitDeadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 expectedAmountOut,
        uint256 slippageBps,
        address[] calldata path,
        uint256 swapDeadline
    )
        external
        nonReentrant
        whenNotPaused
        ensure(swapDeadline)
        returns (uint256 amountOut)
    {
        IERC20Permit(token).permit(
            msg.sender,
            address(this),
            amount,
            permitDeadline,
            v,
            r,
            s
        );

        emit PermitUsed(msg.sender, amount);

        if (amount == 0) {
            revert InvalidAmount();
        }

        if (path.length < 2) {
            revert InvalidPath();
        }

        if (slippageBps > MAX_SLIPPAGE_BPS) {
            revert SlippageTooHigh();
        }

        uint256 minOut =
            SlippageLib.calculateMinAmount(
                expectedAmountOut,
                slippageBps
            );

        address tokenIn = path[0];
        address tokenOut = path[path.length - 1];

        IERC20(tokenIn).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        IERC20(tokenIn).forceApprove(
            address(router),
            amount
        );

        uint256[] memory amounts =
            router.swapExactTokensForTokens(
                amount,
                minOut,
                path,
                msg.sender,
                swapDeadline
            );

        amountOut = amounts[amounts.length - 1];

        unchecked {
            totalVolumeIn[msg.sender] += amount;
            totalSwaps[msg.sender]++;
        }

        emit SwapExecuted(
            msg.sender,
            tokenIn,
            tokenOut,
            amount,
            amountOut
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
}