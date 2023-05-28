// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import { TUIN } from '../../src/optimism-goerli/TUIN.sol';

contract ContractScript is Script {
    address public poolContract = address(0x7cE6B6f6f337B1F36E70F00a749048006C6028CC);

    function setUp() public {}

    function run() public {
        vm.broadcast();
         new TUIN(poolContract);
    }
}


