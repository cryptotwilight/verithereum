// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IGVersion { 
    
    function getName() view external returns (string memory _name);

    function getVersion() view external returns (uint256 _version);

}