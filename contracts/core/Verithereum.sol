// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "../interfaces/IVerithereum.sol";
import "../interfaces/IVRegister.sol";
import "https://github.com/EthSign/sign-protocol-evm/blob/main/src/interfaces/ISP.sol";


contract Verithereum is IVerithereum, IVversion { 

    string constant name = "RESERVED_VERITHEREUM";
    uint256 constant version = 1; 

    string constant SIGN_PROTOCOL = "RESERVED_SIGN_PROTOCOL_ISP";

    IVRegister register; 
    ISP isp; 
    uint256 [] verificationIds;
    mapping(uint256=>GiltVerification) giltVerificationById; 

    constructor(address _register) {
        register = IVRegister(_register);
        isp = ISP(register.getAddress(SIGN_PROTOCOL));
    }

    function getGiltVerificationIds() view external returns (uint256 [] memory _ids){
        return verificationIds; 
    }

    function verify(Gilt memory _gilt) external returns (GiltVerification memory _giltVerification){
        Attestation memory attestation_ = isp.getAttestation(_gilt.attestationId);
        // get the rest

    }

    function getGiltverification(uint256 _giltVerificationId) view external returns (GiltVerification memory _giltVerification){
        return giltVerificationById[_giltVerificationId];
    }


}