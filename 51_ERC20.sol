// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/**
 * @title An ERC20 Contract
 * @author SCP / Lena
 * @dev A contract that represents an ERC20 token
 */

// Interface of ERC20 token
interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed from, address indexed to, uint amount);
}

contract ERC20 is IERC20 {
    uint public totalSupply;

    // Keep track of user balance
    mapping(address => uint) public balanceOf;
    // Keep track of tokens approved to spend by another user: owner -> spender -> amount
    mapping(address => mapping(address => uint)) public allowance;

    // State Variables
    string public name = "Test";
    string public symbol = "TEST";
    uint8 public decimals = 18;

    /**
     * @dev transfer function deducts from the balance of the sender and adds to that of the recipient
     * @param recipient is the address of the recipient
     * @param amount is the amount to be transferred
     * @return true if successful
     */
    function transfer(address recipient, uint amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev approve function allows a user delegate the use of his funds and states the amount
     * @param spender is user of the fund permitted by the owner of the account
     * @param amount of tokens to be transferred
     * @return true if successful
     */
    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev transferFrom function is effective after approval of funds.
     * @param sender is sender of the tokens
     * @param recipient is receiver of the tokens
     * @param amount to be transferred
     * @return true if successful
     */
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    /**
     * @dev mint function creates new tokens
     * @param amount of tokens to be minted
     */
    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    /**
     * @dev burn function destroys tokens
     * @param amount of tokens to be burnt
     */
    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}
