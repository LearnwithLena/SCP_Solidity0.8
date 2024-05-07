// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract MultiSigWallet {
    // Events //
    event Deposit(address indexed sender, uint indexed amount);
    event Approve(address indexed owner, uint indexed txId);
    event Revoke(address indexed owner, uint indexed txId);
    event Execute(uint indexed txId);

    // Struct //
    struct Transaction {
        address to; // address where value is sent
        uint value;
        bytes data;
        bool executed;
    }

    // State Variables
    address[] public owners;
    mapping(address => bool) public isOwner; // address -> if owner(true)
    mapping(uint => mapping(address => bool)) public approved; //txId -> address owner -> approved or not
    Transaction[] public transactions;
    uint public required;

    constructor(address[] memory _owners, uint _required) {
        require(_owners.length > 0, "no owner"); // checks that there are address in the list
        require(
            _required <= _owners.length && _required > 0,
            "not enough approvers"
        );
        // checks that required is less than the lenghth of owners array and greater than 0

        // Loops through the array of owners to get each owner
        for (uint i; i < _owners.length; i++) {
            address owner = _owners[i]; //Gives each array entry an owner variable
            require(owner != address(0), "invaid address"); // Checks its not address(0)
            require(!isOwner[owner], "owner not unique/new"); // Checks that owner is not in isOwner mappping making it a new address for owner

            isOwner[owner] = true; // Change the bool for owner to true in isOwner mapping
            owners.push(owner); // Add owner to array of owners
        }

        required = _required;
    }
}
