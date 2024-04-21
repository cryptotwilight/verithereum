// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Gilt} from "./IGStructs.sol";

interface IGAttestationManager {

    function issueAttestation(Gilt memory _gilt, address _giltVault) external returns (uint256 _attestationId);

    function revoke(uint256 attestationId) external returns (bool _revoked);

}