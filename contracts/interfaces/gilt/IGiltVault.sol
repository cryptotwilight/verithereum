// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import {Gilt} from "./IGStructs.sol";

interface IGiltVault {

    function getGilt() view external returns (Gilt memory _gilt);

    function deposit(Gilt memory _gilt) external payable returns (bool _locked);

    function isLocked() view external returns (bool _locked);

    function withdraw() external returns (bool _closed);

    function isClosed() view external returns (bool _closed);
}