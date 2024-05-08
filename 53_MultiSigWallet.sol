// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/**
 * Title: Multi Signature Wallet
 * Author: SCP/ Lena
 * Description: A multi signature wallet that allows many owner to transact
 */

contract MultiSigWallet {
    // Events //
    event Deposit(address indexed sender, uint indexed amount);
    event Submit(uint indexed txId);
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

    // Modifiers
    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    // Checks that the transaction exists
    modifier txExists(uint _txId) {
        require(_txId < transactions.length, "txn does not exist");
        _;
    }

    // Checks that the transaction is not approved
    modifier notApproved(uint _txId) {
        // requires that approval status is set to false
        require(!approved[_txId][msg.sender], "txn approved");
        _;
    }

    // Checks that the transaction is not executed
    modifier notExecuted(uint _txId) {
        // requires that executed status is set to false
        require(!transactions[_txId].executed, "txn already executed");
        _;
    }

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

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @dev submit sends a transaction to the transactions array, txId is the position of the transaction in the array
     * @param _to address to send to
     * @param _value value to be sent
     * @param _data txn data
     */
    function submit(
        address _to,
        uint _value,
        bytes calldata _data
    ) external onlyOwner {
        transactions.push(
            Transaction({to: _to, value: _value, data: _data, executed: false})
        );
        // transactions.lenghth - 1 = txId, since its 0 based index
        emit Submit(transactions.length - 1);
    }

    /**
     * Approve approves the submitted transaction
     * @param _txId Transaction Id
     */
    function approve(
        uint _txId
    ) external onlyOwner txExists(_txId) notApproved(_txId) notExecuted(_txId) {
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    /**
     * @dev getApprovalCount is a private function that counts the number of approvals for a transaction
     * @param _txId Transaction Id
     */
    function _getApprovalCount(uint _txId) private view returns (uint count) {
        // Get the number of approvals for each owner
        for (uint i; i < owners.length; i++) {
            if (approved[_txId][owners[i]]) {
                count += 1;
            }
        }
    }

    /**
     * @dev executes sends the transaction and changes the bool
     * @param _txId Transaction Id
     */
    function execute(
        uint _txId
    ) external onlyOwner txExists(_txId) notExecuted(_txId) {
        require(_getApprovalCount(_txId) >= required, "not enough approvals");
        Transaction storage transaction = transactions[_txId];
        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );

        require(success, "txn failed");
        emit Execute(_txId);
    }

    /**
     * revokes an already approved transaction
     * @param _txId Transaction id
     */
    function revoke(
        uint _txId
    ) external onlyOwner notExecuted(_txId) txExists(_txId) {
        require(approved[_txId][msg.sender], "transaction not approved");
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }
}
