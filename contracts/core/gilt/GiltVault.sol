// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Gilt} from "../../interfaces/gilt/IGStructs.sol";
import "../../interfaces/gilt/IGiltVault.sol";
import "../../interfaces/gilt/IGVersion.sol";
import "../../interfaces/gilt/IGRegister.sol";

import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract GiltVault is IGiltVault, IGVersion { 

    modifier giltContractOnly  {
        require(msg.sender == register.getAddress(GILT_CONTRACT), "gilt contract only");
        _;
    }   

    string constant name = "GILT_VAULT;";
    uint256 constant version = 1; 
    address immutable self; 

    address constant NATIVE = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    string constant GILT_CONTRACT = "RESERVED_GILT_CONTRACT";

    IGRegister register; 
    Gilt gilt; 

    bool locked; 
    bool closed; 

    constructor(address _register) {
        register = IGRegister(_register);
        self = address(this);

    }

    function getName() pure external returns (string memory _name){
        return name; 
    }

    function getVersion() pure external returns (uint256 _version){
        return version; 
    }

    function getGilt() view external returns (Gilt memory _gilt){
        return gilt; 
    }

    function deposit(Gilt memory _gilt) external giltContractOnly payable returns (bool _locked){
        require(!locked && !closed, "vault locked or closed");
        locked = true; 
        gilt = _gilt; 
       if(_gilt.erc20 == NATIVE){
            require(msg.value >= _gilt.amount, "insufficient funds transmitted");
        }
        else {
            IERC20 erc20_ = IERC20(_gilt.erc20);
            erc20_.transferFrom(msg.sender, self, _gilt.amount);
        }
        return true; 
    }   

    function isLocked() view external returns (bool _locked){
        return locked; 
    }

    function withdraw() external giltContractOnly returns (bool _closed){
        require(locked && !closed, "vault closed");
        closed = true; 
        if(gilt.erc20 == NATIVE) {
            payable(msg.sender).transfer(gilt.amount);
        }
        else {
            IERC20(gilt.erc20).approve(msg.sender, gilt.amount);
        }

        return closed; 
    }   

    function isClosed() view external returns (bool _closed){
        return closed;
    }
}