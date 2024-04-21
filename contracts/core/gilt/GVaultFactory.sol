// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "../../interfaces/gilt/IGVaultFactory.sol";
import "../../interfaces/gilt/IGVersion.sol";
import "../../interfaces/gilt/IGRegister.sol";
import "./GiltVault.sol";


contract GVaultFactory is IGVaultFactory, IGVersion {

    modifier giltContractOnly {
        require(msg.sender == register.getAddress(GILT_CONTRACT), "gilt contract only");
        _;
    }

    string constant name = "RESERVED_G_VAULT_FACTORY";
    uint256 constant version = 1; 

    string constant GILT_CONTRACT = "RESERVED_GILT_CONTRACT";

    IGRegister register; 
    address [] vaults; 
    mapping(address=>bool) isKnown;

    constructor(address _register) {
        register = IGRegister(_register);
    }

    function getName() pure external returns (string memory _name){
        return name; 
    }

    function getVersion() pure external returns (uint256 _version){
        return version; 
    }

    function getGiltVaults() view external returns (address [] memory _vaults) {
        return vaults;
    }

    function isKnownVault(address _address) view external returns (bool _isKnown) {
        return isKnown[_address];
    }

    function getGiltVault() external giltContractOnly returns (address _vault){
        IGiltVault vault_ = new GiltVault(address(register));
        _vault = address(vault_);
        vaults.push(_vault);
        isKnown[_vault] = true; 
        return _vault;
    }
}