// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/**
 * @title Piggy Bank App
 * @author SPC/ Lena
 * @notice This contract is untested
 * @dev A contract that receives ether from user, but should only withdraw to the owner of the contract
 */
contract PiggyBank {
    // Events //
    event Receive(uint amount);
    event Withdraw(uint amount);

    address public owner = msg.sender;

    receive() external payable {
        emit Receive(msg.value);
    }

    /**
     * @dev function that withdraws all the ether deposited into the contract
     */
    function withdraw() external {
        require(msg.sender == owner, "Not Owner");
        emit Withdraw(address(this).balance);
        selfdestruct(payable(msg.sender));
    }
}
