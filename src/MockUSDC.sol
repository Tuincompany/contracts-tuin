// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSDC is ERC20 {
    constructor() ERC20("US DOLLAR COIN", "USDC") {
        _mint(msg.sender, 5000000000000000000000000e18);
    }
}
