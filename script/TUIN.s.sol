// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import { TUIN } from 'src/TUIN.sol';

contract ContractScript is Script {
    address public poolContract = address(0xF376C4e00Ff6E475de07B483a17fd6Cf35cD62Cb);

    function setUp() public {}

    function run() public {
        vm.broadcast();
         new TUIN(poolContract, true);
    }
}



