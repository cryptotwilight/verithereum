// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import {Gilt} from "./gilt/IGStructs.sol";

struct GiltVerificationProof {
    uint256 id; 
    string proof; 
    Gilt gilt; 
    uint256 createDate;
}