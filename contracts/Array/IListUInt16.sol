//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.6.0;

//Interface to compare different list implementaions
interface IListUInt16 {
    function length() external view returns (uint256);

    function get(uint256 i) external view returns (uint16);

    function set(uint256 i, uint16 val) external;

    function push(uint16 val) external;

    function swap(uint256 i, uint256 j) external;

    function pop() external;
}
