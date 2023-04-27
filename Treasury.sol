// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@aave/protocol-v2/contracts/interfaces/ILendingPool.sol";

contract Treasury is Ownable {
    using SafeERC20 for IERC20;

    IUniswapV2Router02 public uniswapRouter;
    IAaveLendingPool public aaveLendingPool;

    address public usdcToken;
    address public usdtToken;
    address public daiToken;

    uint256 public uniswapRatio;
    uint256 public aaveRatio;

    constructor(
        address _uniswapRouter,
        address _aaveLendingPool,
        address _usdcToken,
        address _usdtToken,
        address _daiToken
    ) {
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        aaveLendingPool = IAaveLendingPool(_aaveLendingPool);
        usdcToken = _usdcToken;
        usdtToken = _usdtToken;
        daiToken = _daiToken;
    }

    function setRatios(
        uint256 _uniswapRatio,
        uint256 _aaveRatio
    ) external onlyOwner {
        require(_uniswapRatio + _aaveRatio == 100, "Ratios must add up to 100");
        uniswapRatio = _uniswapRatio;
        aaveRatio = _aaveRatio;
    }

    function deposit(uint256 amount) external {
        // Transfer USDC from sender to the contract
        IERC20(usdcToken).safeTransferFrom(msg.sender, address(this), amount);

        // Calculate distribution amounts based on ratios
        uint256 uniswapAmount = (amount * uniswapRatio) / 100;
        uint256 aaveAmount = (amount * aaveRatio) / 100;

        // Approve Uniswap and AAVE to spend USDC
        IERC20(usdcToken).safeApprove(address(uniswapRouter), uniswapAmount);
        IERC20(usdcToken).safeApprove(address(aaveLendingPool), aaveAmount);

        // Deposit funds into Uniswap and swap for USDT
        address[] memory path = new address[](2);
        path[0] = usdcToken;
        path[1] = usdtToken;

        uniswapRouter.swapExactTokensForTokens(
            uniswapAmount,
            0,
            path,
            address(this),
            block.timestamp + 600
        );

        // Deposit funds into AAVE and swap for DAI
        aaveLendingPool.deposit(usdcToken, aaveAmount, address(this), 0);
    }

    function withdraw(uint256 amount) external onlyOwner {
        IERC20(usdtToken).safeTransfer(
            msg.sender,
            (amount * uniswapRatio) / 100
        );
        IERC20(daiToken).safeTransfer(msg.sender, (amount * aaveRatio) / 100);
    }

    function calculateYield() public view returns (uint256) {
        uint256 usdtBalance = IERC20(usdtToken).balanceOf(address(this));
        uint256 daiBalance = IERC20(daiToken).balanceOf(address(this));

        return usdtBalance + daiBalance;
    }
}
