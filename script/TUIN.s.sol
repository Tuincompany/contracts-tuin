// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import { TUIN } from 'src/TUIN.sol';

contract ContractScript is Script {
    address public poolContract = address(0x5c181549688C3dd4148d9e8Bf4EBd0d3cc9de3C5);

    function setUp() public {}

    function run() public {
        vm.broadcast();
         new TUIN(poolContract);
    }
}


