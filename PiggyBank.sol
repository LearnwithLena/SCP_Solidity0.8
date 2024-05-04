// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract PiggyBank {

    // Events
    event Receive(uint amount);
    event Withdraw(uint amount);

    address public owner = msg.sender;

    receive() external payable{
        emit Receive(uint msg.value);
    }

    function Withdraw() external {
        require(msg.sender == owner, "Not Owner");
        emit Withdraw(address(this).balance);
        selfdestruct(msg.sender);
    }
}