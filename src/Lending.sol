// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IPriceOracle {
    function getAssetPrice(address _asset) external view returns (uint256);
    function getAssetsPrices(address[] calldata _assets) external view returns(uint256[] memory);
    function getSourceOfAsset(address _asset) external view returns(address);
    function getFallbackOracle() external view returns(address);
}

contract UpsideAcademyLending {
    address public usdc;
    IPriceOracle public priceOracle;

    constructor(IPriceOracle _priceOracle, address _usdc) {
        priceOracle = _priceOracle;
        usdc = _usdc;
    }

    function initializeLendingProtocol(address token) external payable {
        
    }

    function deposit(address token, uint256 amount) external payable {
        
    }

    function withdraw(address token, uint256 amount) external {
        
    }

    function borrow(address token, uint256 amount) external {
        
    }

    function repay(address token, uint256 amount) external {
        
    }

    function liquidate(address borrower, address token, uint256 amount) external {
        
    }

    function getAccruedSupplyAmount(address token) external returns (uint256) {
        
    }
}

contract UpsideOracle {
    address public operator;
    mapping(address => uint256) prices;

    constructor() {
        operator = msg.sender;
    }

    function getPrice(address token) external returns (uint256) {
        
    }

    function setPrice(address token, uint256 price) external {
        
    }
}