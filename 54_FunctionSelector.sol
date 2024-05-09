// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/**
 * @title Function Selector
 * @author SCF/ Lena
 * @notice This contract shows how function selectors operate
 */

contract FunctionSelector {
    /**
     *@dev selector converts the string of the passed in function along with its parameters after keccack 256 hash to four bytes
     * @param _func string to be passed as function
     */
    function selector(string calldata _func) external pure returns (bytes4) {
        return bytes4(keccak256(bytes(_func)));
        // "transfer(address,uint256)" how it was passed in.
        // 0xa9059cbb
    }
}

contract Receive {
    event Log(bytes data);

    function transfer(address _to, uint256 _amount) external {
        emit Log(msg.data);
        // 0xa9059cbb
        // 0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4 || hex of the address 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
        // 000000000000000000000000000000000000000000000000000000000000000b || hex of the amount 11
        // How?:take thte string of function, hash
    }
}
