// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import {Gilt} from "./IGiltStructs.sol";

struct GiltVerification  { 
    uint256 id; 
    Gilt gilt; 
    string verificationOutcome; 
    uint256 verificationDate; 
}