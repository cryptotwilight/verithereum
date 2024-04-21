// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface IVeriRegister {

    function getName(address _address) view external returns (string memory _name);

    function getAddress(string memory _name) view external returns (address _address);

    function getNValue(string memory _name) view external returns (uint256 _value);

}