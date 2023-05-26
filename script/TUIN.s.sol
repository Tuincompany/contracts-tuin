// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import { TUIN } from 'src/TUIN.sol';

contract ContractScript is Script {
    address public poolContract = address(0x047090139a1473263dDd711068cA10A476cA6BBF);

    function setUp() public {}

    function run() public {
        vm.broadcast();
         new TUIN(poolContract, true);
    }
}



