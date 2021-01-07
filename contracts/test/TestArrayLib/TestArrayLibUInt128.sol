pragma solidity >=0.6.0;
import '../../Array/IListUInt128.sol';
import '../../Array/ArrayLibUInt128.sol';

contract TestArrayLibUInt128 is IListUInt128 {
    using ArrayLibUInt128 for bytes32;
    bytes32 constant array = bytes32(uint256(0));
    uint256 arrayLength;

    function length() external view override returns (uint256) {
        return array.len();
    }

    function get(uint256 i) external view override returns (uint128) {
        return array.get(i);
    }

    function set(uint256 i, uint128 val) external override {
        array.set(i, val);
    }

    function push(uint128 val) external override {
        array.push(val);
    }

    function swap(uint256 i, uint256 j) external override {
        array.swap(i, j);
    }

    function pop() external override {
        array.pop();
    }
}
