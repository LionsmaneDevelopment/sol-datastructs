//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

//Interface to compare different list implementaions
interface IListUInt64 {
    function length() external view returns (uint256);

    function get(uint256 i) external view returns (uint64);

    function set(uint256 i, uint64 val) external;

    function push(uint64 val) external;

    function swap(uint256 i, uint256 j) external;

    function pop() external;
}
