//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

/**
 * @dev A gas optimized uintX[] implementation. The bitLength param determines the size
 * of the stored value. This can be a min of 1 and a maximum of 256.
 *
 * The array saves gas by avoiding bounds checks and tightly packing uintX elements.
 * The recommended use for this library is to derive from it a ArrayLibUintX library specific
 * to a hard-coded bitLength and then use that library within contracts.
 *
 * The storage layout conforms to the Solidity standard as described at
 * https://docs.soliditylang.org/en/latest/internals/layout_in_storage.html
 *
 * Potential improvements:
 *  - Optimized batch inserts and reads
 *  - Optimized swaps
 *  - Bounds checked save insert
 */
library ArrayLibUInt {
    /**
     * @dev Get length of the array
     * @param slot storage slot
     * @return length
     *
     * This function is here as a helper to avoid inline assembly (though less efficient).
     * It also helps to show how the arrays' length is stored in its designated slot.
     */
    function len(bytes32 slot) internal view returns (uint256 length) {
        assembly {
            length := sload(slot)
        }
    }

    /**
     * @dev Get item at array[i]
     * @param bitLength uint bit length
     * @param slot storage slot
     * @param i index
     * @return val
     *
     * The array storage layout is divided in slots starting at keccak(slot).
     * Storage slots can store up to 256/bitLength items since one slot is 256 bits.
     * The get() cleans up the higher-order bits for you ensuring safety when converting.
     * See https://solidity.readthedocs.io/en/v0.7.0/internals/variable_cleanup.html
     */
    function get(
        uint8 bitLength,
        bytes32 slot,
        uint256 i
    ) internal view returns (uint256 val) {
        uint256 slotPerStorage = 256 / bitLength;
        uint256 bitMask = ~(uint256(-1) << bitLength); // 000...FFFF

        assembly {
            mstore(0x0, slot)
            let p := keccak256(0x0, 0x20) //array[0] storage
            let idx := add(p, div(i, slotPerStorage)) //array[idx] storage
            let start := mul(sub(sub(slotPerStorage, 1), mod(i, slotPerStorage)), bitLength) //start pos

            let storedVal := sload(idx) //load cur value
            val := shr(start, storedVal) //Clean bits here
        }

        val = val & bitMask;
    }

    /**
     * @dev Set array[i] = val
     * @param bitLength uint bit length
     * @param slot storage slot
     * @param i index
     * @param val value
     */
    function set(
        uint8 bitLength,
        bytes32 slot,
        uint256 i,
        uint256 val
    ) internal {
        uint256 slotPerStorage = 256 / bitLength;
        uint256 bitMask = ~(uint256(-1) << bitLength); // 000...FFFF
        val = val & bitMask;

        assembly {
            mstore(0x0, slot)
            let p := keccak256(0x0, 0x20) //array[0] storage
            let idx := add(p, div(i, slotPerStorage)) //array[idx] storage
            let start := mul(sub(sub(slotPerStorage, 1), mod(i, slotPerStorage)), bitLength) //start pos

            let storedVal := sload(idx) //load cur value
            let newVal := shl(start, val) //shift left logical to start pos
            let bitmask := not(shl(start, bitMask))
            let newStoredVal := or(and(storedVal, bitmask), newVal) //clears old value and inserts new

            sstore(idx, newStoredVal)
        }
    }

    /**
     * @dev Append val to the end of the array, increasing its length.
     * @param bitLength uint bit length
     * @param slot storage slot
     * @param val value
     */
    function push(
        uint8 bitLength,
        bytes32 slot,
        uint256 val
    ) internal {
        uint256 slotPerStorage = 256 / bitLength;
        uint256 bitMask = ~(uint256(-1) << bitLength); // 000...FFFF
        val = val & bitMask;

        assembly {
            mstore(0x0, slot)
            let p := keccak256(0x0, 0x20) //array[0] storage
            let length := sload(slot) //array length
            let idx := add(p, div(length, slotPerStorage)) //array[idx] storage
            let start := mul(sub(sub(slotPerStorage, 1), mod(length, slotPerStorage)), bitLength) //start pos

            let storedVal := sload(idx) //load cur value
            let newVal := shl(start, val) //shift left logical to start pos
            let bitmask := not(shl(start, bitMask))
            let newStoredVal := or(and(storedVal, bitmask), newVal) //clears old value and inserts new

            sstore(idx, newStoredVal)
            sstore(slot, add(length, 1)) //increase length
        }
    }

    /**
     * @dev Pop end val of the array, decreasing its length.
     * @param bitLength uint bit length
     * @param slot storage slot
     */
    function pop(uint8 bitLength, bytes32 slot) internal {
        uint256 slotPerStorage = 256 / bitLength;
        uint256 bitMask = ~(uint256(-1) << bitLength); // 000...FFFF

        uint256 length;
        assembly {
            length := sload(slot)
        }

        uint256 remainder = length % slotPerStorage;
        if (remainder == 1) {
            //pop slot to get gas refund
            uint256 quotient = length / slotPerStorage;
            assembly {
                mstore(0x0, slot)
                let p := keccak256(0x0, 0x20) //array[0] storage
                let idx := add(p, quotient)
                sstore(idx, 0) //clear storage
            }
        }

        assembly {
            sstore(slot, sub(length, 1)) //decrease length
        }
    }

    /**
     * @dev Swap two values at i, j.
     * @param bitLength uint bit length
     * @param slot storage slot
     * @param i index
     * @param j subindex
     *
     * There is potential for optimizing how same slot items are swapped.
     */
    function swap(
        uint8 bitLength,
        bytes32 slot,
        uint256 i,
        uint256 j
    ) internal {
        //Naive implementation
        uint256 a = get(bitLength, slot, i);
        uint256 b = get(bitLength, slot, j);
        set(bitLength, slot, i, b);
        set(bitLength, slot, j, a);
    }

    /**
     * @dev Get a batch of items.
     * @param bitLength uint bit lengthh
     * @param slot storage slot
     * @param iArray index array
     * @return valList
     *
     * TODO: optimize for bitpacked SLOAD
     */
    function getBatch(
        uint8 bitLength,
        bytes32 slot,
        uint256[] memory iArray
    ) internal view returns (uint256[] memory valList) {
        valList = new uint256[](iArray.length);

        for (uint256 i = 0; i < iArray.length; i++) {
            valList[i] = get(bitLength, slot, iArray[i]);
        }
    }

    /**
     * @dev Set a batch of values in the array.
     * @param bitLength uint bit length
     * @param slot storage slot
     * @param iArray index array
     * @param valArray value array
     *
     * TODO: optimize for bitpacked SSTORE
     */
    function setBatch(
        uint8 bitLength,
        bytes32 slot,
        uint256[] memory iArray,
        uint256[] memory valArray
    ) internal {
        require(iArray.length == valArray.length);

        for (uint256 i = 0; i < iArray.length; i++) {
            set(bitLength, slot, iArray[i], valArray[i]);
        }
    }

    /**
     * @dev Append a batch of values to the end of the array, increasing its length.
     * @param bitLength uint bit length
     * @param slot storage slot
     * @param valArray value array
     *
     * TODO: optimize for bitpacked SSTORE
     */
    function pushBatch(
        uint8 bitLength,
        bytes32 slot,
        uint256[] memory valArray
    ) internal {
        for (uint256 i = 0; i < valArray.length; i++) {
            push(bitLength, slot, valArray[i]);
        }
    }

    /**
     * @dev Pop a batch of values from the array, decreasing its length.
     * @param bitLength uint bit length
     * @param slot storage slot
     * @param n number of times to pop
     *
     * TODO: optimize for bitpacked SSTORE
     */
    function popBatch(
        uint8 bitLength,
        bytes32 slot,
        uint256 n
    ) internal {
        for (uint256 i = 0; i < n; i++) {
            pop(bitLength, slot);
        }
    }
}
