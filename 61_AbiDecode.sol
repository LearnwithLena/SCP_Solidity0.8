// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract AbiDecode {
    struct MyStruct {
        string name;
        uint[2] nums;
    }

    function encode(
        uint x,
        address addr,
        uint[] calldata arr,
        MyStruct calldata mystruct
    ) external pure returns (bytes memory) {
        return abi.encode(x, addr, arr, mystruct);
    }

    function decode(
        bytes memory data
    )
        external
        pure
        returns (
            uint x,
            address addr,
            uint[] memory arr,
            MyStruct memory mystruct
        )
    {
        (x, addr, arr, mystruct) = abi.decode(
            data,
            (uint, address, uint[], MyStruct)
        );
    }
}
