// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import {Gilt, ProtoGilt} from "./IGStructs.sol";

interface IGiltContract {

    function getGiltIds() view external returns (uint256 [] memory _ids);

    function getGilt(uint256 _id) view external returns (Gilt memory _gilt);

    function getGiltVault(uint256 _giltId) view external returns (address _giltVault);

    function mintGilt(ProtoGilt memory _protoGilt) external payable returns (uint256 _giltId);

    function liquidateGilt(uint256 _giltId, address _to) external returns (uint256 _liquidationId);
}