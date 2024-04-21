// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface IVversion { 

    function getName() view external returns (string memory _name);

    function getVersion() view external returns (uint256 _version);
}