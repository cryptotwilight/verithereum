// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import {Gilt} from "../IGStructs.sol";

struct Loan {
    uint256 id; 
    uint256 amount; 
    uint256 balance; 
    uint256 interest; 
    uint256 date; 
    address owner; 
    Gilt collateral; 
}

struct Liquidity {
    uint256 id; 
    uint256 amount; 
    uint256 date; 
    address owner; 
}

struct GiltTx {
    uint256 id; 
    Gilt gilt;
    string txType; 
    uint256 date; 
}

struct LoanTx {
    uint256 id; 
    Loan loan; 
    string txType; 
    uint256 date; 

}

struct LiquidityTx {
    uint256 id; 
    Liquidity liquidity; 
    string txType; 
    uint256 date; 
}

interface IGiltLiquidityPool {

    function getPoolErc20() view external returns (address _erc20);
    

    function depositGilt(Gilt memory _gilt) external returns (uint256 _giltTxId);

    function withdrawGilt(uint256 _giltTxId) external returns (uint256 giltTxId);

    function getGiltTxId(uint256 _giltTxId) view external returns (GiltTx memory _giltTx);

    
    function borrow(uint256 _amount) external returns (uint256 _loanId);

    function repay(uint256 _amount) external payable returns (uint256 _loanTxId);

    function getLoan(uint256 _loanId) external returns (Loan memory _loan);


    function getLiquidity(uint256 _liquidityTxId) view external returns (Liquidity memory _liquidity);

    function addLiquidity(uint256 _amount) external payable returns (uint256 _liquidityTxId);

    function removeLiquidity(uint256 _amount) external returns (uint256 _liquidityTxId);

}   