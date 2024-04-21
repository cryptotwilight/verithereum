// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "../interfaces/IVeriRegister.sol";
import "../interfaces/IVversion.sol";

struct VeriConfig {
    string name; 
    uint256 version; 
    address address_; 
}
contract VeriRegister is IVeriRegister, IVversion { 

    modifier adminOnly { 
        require(msg.sender == addressByName[ADMIN], "admin only");
        _;
    }

    string constant name = "RESERVED_VERI_REGISTER";
    uint256 constant version = 1; 
    address immutable self; 

    string constant ADMIN = "RESERVED_VERI_ADMIN";

    string [] names; 
    mapping(string=>bool) knownName; 
    mapping(address=>bool) knownAddress; 

    mapping(string=>uint256) nvalueByName; 
    mapping(address=>string) nameByAddress; 
    mapping(string=>address) addressByName; 
    mapping(address=>uint256) versionByAddress; 

    constructor(address _admin) {
        self = address(this);
        addAddressInternal(ADMIN, _admin, 0);
        addAddressInternal(name, self, version);
    }

    function getName() pure external returns (string memory _name){
        return name; 
    } 

    function getVersion() pure external returns (uint256 _version){
        return version; 
    }
    
    function getName(address _address) view external returns (string memory _name){
        return nameByAddress[_address];
    }

    function getAddress(string memory _name) view external returns (address _address){
        return addressByName[_name];
    }

    function getNValue(string memory _name) view external returns (uint256 _value){
        return nvalueByName[_name];
    }
    function getAddresses() view external adminOnly returns (VeriConfig [] memory _config) {
        _config = new VeriConfig[](names.length);
        for(uint256 x = 0; x < _config.length; x++) {
            string memory name_ = names[x];
            IVversion v_ = IVversion(addressByName[name_]);
            _config[x] = VeriConfig({
                                    name : names[x],
                                    version : versionByAddress[address(v_)],
                                    address_ : address(v_)
                                });
        }
        return _config; 
    }

    function addVersionAddress(address _address) adminOnly external returns (bool _added) {
        require(!knownAddress[_address], "already added");
        IVversion v_ = IVversion(_address);
        return addAddressInternal(v_.getName(), _address, v_.getVersion());
    }

    function addAddress(string memory _name, address _address, uint56 _version) adminOnly external returns (bool _added) {
        return addAddressInternal(_name, _address, _version); 
    }
    //============================ INTERNAL ===========================

    function addAddressInternal(string memory _name, address _address, uint256 _version) internal returns (bool _added) {
        if(!knownName[_name]){
            names.push(_name);
            knownName[_name] = true; 
        }
        
        nameByAddress[_address] = _name;  
        addressByName[_name] = _address; 
        knownAddress[_address] = true;  
        versionByAddress[_address] = _version;
        return true; 
    }
}

