// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import {GiltVerification, Gilt} from "./IVerithereumStructs.sol";

interface IVerithereum  { 

    function getGiltVerificationIds() view external returns (uint256 [] memory _ids);

    function verify(Gilt memory _gilt) external returns (GiltVerification memory _giltVerification);

    function getGiltverification(uint256 _giltVerificationId) view external returns (GiltVerification memory _giltVerification);


}