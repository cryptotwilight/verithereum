// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "../../interfaces/gilt/IGAttestationManager.sol";
import "../../interfaces/gilt/IGVersion.sol";
import "../../interfaces/gilt/IGRegister.sol";

import { ISP } from "@ethsign/sign-protocol-evm/src/interfaces/ISP.sol";
import { Attestation } from "@ethsign/sign-protocol-evm/src/models/Attestation.sol";
import { DataLocation } from "@ethsign/sign-protocol-evm/src/models/DataLocation.sol";

contract GAttestationManager is IGAttestationManager, IGVersion {

    modifier giltContractOnly { 
        require(msg.sender == register.getAddress(GILT_CONTRACT)," gilt contract only ");
        _;
    }

    string constant name = "RESERVED_G_ATTESTATION_MANAGER";
    uint256 constant version = 1; 

    string constant GILT_CONTRACT   = "RESERVED_GILT_CONTRACT";
    string constant SCHEMA_ID       = "RESERVED_ATTESTATION_SCHEMA_ID";
    string constant SIGN_PROTOCOL   = "RESERVED_SIGN_PROTOCOL";

    IGRegister register; 
    uint256 schemaId; 
    ISP signProtocol; 

    mapping(uint256=>Attestation) attestationById;

    constructor(address _register) {
        register = IGRegister(_register);
        initialize();
    }

    function getName() pure external returns (string memory _name){
        return name; 
    }

    function getVersion() pure external returns (uint256 _version){
        return version; 
    }

    function getAttestation(uint256 _attestationId) view external returns (Attestation memory ) {
        return attestationById[_attestationId];
    }

    function issueAttestation(Gilt memory _gilt, address _giltVault) external giltContractOnly returns (uint256 _attestationId){

        bytes memory data_ = abi.encode(_gilt, _giltVault);
        bytes[] memory recipients = new bytes[](1);
        recipients[0] = abi.encode(msg.sender);

        Attestation memory a_ = Attestation({
                                                schemaId: uint64(schemaId),
                                                linkedAttestationId: 0,
                                                attestTimestamp: 0,
                                                revokeTimestamp: 0,
                                                attester: address(this),
                                                validUntil: 0,
                                                dataLocation: DataLocation.ONCHAIN,
                                                revoked: false,
                                                recipients: recipients,
                                                data: data_ // SignScan assumes this is from `abi.encode(...)`
                                            });
            
        _attestationId = signProtocol.attest(a_, "", "", "");
        attestationById[_attestationId] = a_;
        return _attestationId; 
    }

    function revoke(uint256 _attestationId) external giltContractOnly returns (bool _revoked){
        signProtocol.revoke(uint64(_attestationId),"LIQUIDATION",0,"","");
        return true; 
    }

    //=================================================== INTERNAL ==========================================

    function initialize() internal returns (bool _initializd) {
        schemaId = register.getNValue(SCHEMA_ID);
        signProtocol = ISP(register.getAddress(SIGN_PROTOCOL));
        return true; 
    }

}