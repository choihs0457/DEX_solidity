// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/utils/math/Math.sol";

contract Dex {
    ERC20 public tokenX;
    ERC20 public tokenY;
    uint256 public totalLP;
    uint256 public liquidityX;
    uint256 public liquidityY;
    mapping(address => uint256) public lpBalances;

    constructor(address address1_, address address2_) {
        tokenX = ERC20(address1_);
        tokenY = ERC20(address2_);
    }

    modifier updateLiquidity() {
        uint256 currentBalanceX = tokenX.balanceOf(address(this));
        uint256 currentBalanceY = tokenY.balanceOf(address(this));
        
        liquidityX = currentBalanceX;
        liquidityY = currentBalanceY;
        _;
    }

    function addLiquidity(uint256 amountX, uint256 amountY, uint256 minLPReturn) public updateLiquidity returns (uint256) {
        uint256 lpAmount;
        if (totalLP == 0) {
            lpAmount = Math.sqrt(amountX * amountY);
        } else {
            uint256 xRatio = (amountX * totalLP) / liquidityX;
            uint256 yRatio = (amountY * totalLP) / liquidityY;
            lpAmount = Math.min(xRatio, yRatio);
        }

        require(lpAmount > 0 && lpAmount >= minLPReturn, "AddLiquidity minimum LP return error");
        require(tokenX.allowance(msg.sender, address(this)) >= amountX && tokenY.allowance(msg.sender, address(this)) >= amountY,
                "ERC20: insufficient allowance");
        require(tokenX.balanceOf(msg.sender) >= amountX && tokenY.balanceOf(msg.sender) >= amountY,
                "ERC20: transfer amount exceeds balance");

        liquidityX += amountX;
        liquidityY += amountY;
        totalLP += lpAmount;
        lpBalances[msg.sender] += lpAmount;
        
        tokenX.transferFrom(msg.sender, address(this), amountX);
        tokenY.transferFrom(msg.sender, address(this), amountY);

        return lpAmount;
    }

    function removeLiquidity(uint256 lpAmount, uint256 minAmountX, uint256 minAmountY) public updateLiquidity returns (uint256, uint256) {
        require(lpBalances[msg.sender] >= lpAmount, "Insufficient LP tokens");

        uint256 amountX = (liquidityX * lpAmount) / totalLP;
        uint256 amountY = (liquidityY * lpAmount) / totalLP;
        require(amountX >= minAmountX && amountY >= minAmountY, "LP error");

        liquidityX -= amountX;
        liquidityY -= amountY;
        totalLP -= lpAmount;
        lpBalances[msg.sender] -= lpAmount;

        tokenX.transfer(msg.sender, amountX);
        tokenY.transfer(msg.sender, amountY);

        return (amountX, amountY);
    }

    function swap(uint256 amountXIn, uint256 amountYIn, uint256 minAmountOut) public updateLiquidity returns (uint256) {
        require(amountXIn == 0 || amountYIn == 0, "One input must be zero");

        uint256 amountOut;
        if (amountXIn > 0) {
            uint256 newY = (liquidityX * liquidityY) / (liquidityX + amountXIn);
            amountOut = liquidityY - newY;
            amountOut = (amountOut * 999) / 1000; // 0.1% fee
            require(amountOut >= minAmountOut, "Insufficient output amount");

            liquidityX += amountXIn;
            liquidityY -= amountOut;
            tokenX.transferFrom(msg.sender, address(this), amountXIn);
            tokenY.transfer(msg.sender, amountOut);
        } else {
            uint256 newX = (liquidityX * liquidityY) / (liquidityY + amountYIn);
            amountOut = liquidityX - newX;
            amountOut = (amountOut * 999) / 1000; // 0.1% fee
            require(amountOut >= minAmountOut, "Insufficient output amount");

            liquidityY += amountYIn;
            liquidityX -= amountOut;
            tokenY.transferFrom(msg.sender, address(this), amountYIn);
            tokenX.transfer(msg.sender, amountOut);
        }

        return amountOut;
    }
}