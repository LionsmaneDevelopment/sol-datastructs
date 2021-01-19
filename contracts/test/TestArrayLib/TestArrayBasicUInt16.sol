//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
import '../../Array/IListUInt16.sol';

contract TestArrayBasicUInt16 is IListUInt16 {
    uint16[] array;

    function length() public view override returns (uint256) {
        return array.length;
    }

    function get(uint256 i) public view override returns (uint16) {
        return array[i];
    }

    function set(uint256 i, uint16 val) public override {
        array[i] = val;
    }

    function push(uint16 val) public override {
        array.push(val);
    }

    function swap(uint256 i, uint256 j) public override {
        (array[i], array[j]) = (array[j], array[i]);
    }

    function pop() external override {
        array.pop();
    }
}
