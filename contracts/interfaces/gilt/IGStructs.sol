// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

struct Gilt {
    uint256 id;
    address erc20; 
    uint256 amount;
    address giltContract; 
    uint256 createDate; 
    uint256 chainId;
    string status;
    uint256 attestationId;
}

struct ProtoGilt {

    address erc20; 
    uint256 amount;
    uint256 chainId;
}

struct GiltLiquidation {
    uint256 id;
    Gilt gilt; 
    uint256 liquidationDate;
    address recipient; 
}
