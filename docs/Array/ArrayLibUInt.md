## `ArrayLibUInt`

A gas optimized uintX[] implementation. The bitLength param determines the size
of the stored value. This can be a min of 1 and a maximum of 256.

The array saves gas by avoiding bounds checks and tightly packing uintX elements.
The recommended use for this library is to derive from it a ArrayLibUintX library specific
to a hard-coded bitLength and then use that library within contracts.

The storage layout conforms to the Solidity standard as described at
https://docs.soliditylang.org/en/latest/internals/layout_in_storage.html

Potential improvements:

-   Optimized batch inserts and reads
-   Optimized swaps
-   Bounds checked save insert

### `len(bytes32 slot) → uint256 length` (internal)

Get length of the array

### `get(uint8 bitLength, bytes32 slot, uint256 i) → uint256 val` (internal)

Get item at array[i]

### `set(uint8 bitLength, bytes32 slot, uint256 i, uint256 val)` (internal)

Set array[i] = val

### `push(uint8 bitLength, bytes32 slot, uint256 val)` (internal)

Append val to the end of the array, increasing its length.

### `pop(uint8 bitLength, bytes32 slot)` (internal)

Pop end val of the array, decreasing its length.

### `swap(uint8 bitLength, bytes32 slot, uint256 i, uint256 j)` (internal)

Swap two values at i, j.

### `getBatch(uint8 bitLength, bytes32 slot, uint256[] iArray) → uint256[] valList` (internal)

Get a batch of items.

### `setBatch(uint8 bitLength, bytes32 slot, uint256[] iArray, uint256[] valArray)` (internal)

Set a batch of values in the array.

### `pushBatch(uint8 bitLength, bytes32 slot, uint256[] valArray)` (internal)

Append a batch of values to the end of the array, increasing its length.

### `popBatch(uint8 bitLength, bytes32 slot, uint256 n)` (internal)

Pop a batch of values from the array, decreasing its length.
