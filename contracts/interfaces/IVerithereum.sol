// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import {Gilt, GiltVerificationProof} from "./IVStructs.sol";

interface IVerithereum {

    function verify(Gilt memory _gilt) external returns (GiltVerificationProof memory _gvp);

    function getGVPIds() view external returns (uint256 [] memory _ids);

    function getGiltVerificationProof(uint256 _gvpId) external returns (GiltVerificationProof memory _gvp);

}