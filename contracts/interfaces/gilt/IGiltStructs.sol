// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

struct Gilt  { 
    uint256 id; 
    address erc20; 
    uint256 amount; 
    address giltContract; 
    uint256 attestationId; 
    uint256 createDate; 
    uint256 liquidationDate; 
}