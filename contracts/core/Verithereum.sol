// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "../interfaces/IVerithereum.sol";
import "../interfaces/IVversion.sol";
import "../interfaces/IVeriRegister.sol";

import { Attestation } from "@ethsign/sign-protocol-evm/src/models/Attestation.sol";
import { DataLocation } from "@ethsign/sign-protocol-evm/src/models/DataLocation.sol";
import { ISP } from "@ethsign/sign-protocol-evm/src/interfaces/ISP.sol";

contract Verithereum is IVerithereum, IVversion {

    modifier adminOnly {
        require(msg.sender == register.getAddress(ADMIN), "admin only");
        _;
    }

    string constant name = "RESERVED_VERITHEREUM_CORE";
    uint256 constant version = 1; 

    string constant SIGN_PROTOCOL = "RESERVED_SIGN_PROTOCOL";
    string constant ADMIN = "RESERVED_VERI_ADMIN";
    string constant REGISTER = "RESERVED_VERI_REGISTER";

    IVeriRegister register; 
    ISP signProtocol;

    uint256 [] gvpIds; 
    mapping(uint256=>GiltVerificationProof) proofById; 

    constructor(address _register) {
        register = IVeriRegister(_register);
        initialize(); 
    }

    function getName() pure external returns (string memory _name){
        return name; 
    }

    function getVersion() pure external returns (uint256 _version){
        return version; 
    }

    function getGVPIds() view external returns (uint256 [] memory _ids){
        return gvpIds; 
    }

    function getGiltVerificationProof(uint256 _gvpId) view external returns (GiltVerificationProof memory _gvp){
        return proofById[_gvpId];
    }

    function verify(Gilt memory _gilt) external returns (GiltVerificationProof memory _gvp){
        Attestation memory 


    }

    function notifyChangeOfAddress() external adminOnly returns (bool _acknowledged) {
        register = IVeriRegister(register.getAddress(REGISTER));
        initialize(); 
        return true; 
    }

//================================= INTERNAL =====================================================

    function initialize() internal returns (bool _initialized){
        signProtocol = ISP(register.getAddress(SIGN_PROTOCOL));
        return true; 
    }



}