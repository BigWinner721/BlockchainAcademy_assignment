// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FunToken is ERC20 {
    constructor() ERC20("Fun Token", "FT") {
        _mint(msg.sender, 1000000000 * 10 ** decimals());
    }
}
