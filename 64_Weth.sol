// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// import "@rari-capital/solmate/src/tokens/ERC20.sol";
import "./IERC20.sol";

contract WETH is ERC20 {
    event Deposit(address indexed user, uint amount);
    event Withdraw(address indexed user, uint amount);

    constructor() ERC20("Wrapped Eth", "ETH", 18) {}

    fallback() external payable {
        deposit();
    }

    function deposit() public payable {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint _amount) external {
        _burn(msg.sender, _amount);
        payable((msg.sender)).transfer(_amount);
        emit Withdraw(msg.sender, _amount);
    }
}
