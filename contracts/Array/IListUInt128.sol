//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

//Interface to compare different list implementaions
interface IListUInt128 {
    function length() external view returns (uint256);

    function get(uint256 i) external view returns (uint128);

    function set(uint256 i, uint128 val) external;

    function push(uint128 val) external;

    function swap(uint256 i, uint256 j) external;

    function pop() external;
}
