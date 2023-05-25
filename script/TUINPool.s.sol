// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import { TUINPool } from '../src/TUINPool.sol';

contract ContractScript is Script {
    

    function setUp() public {
       
    }

    function run() public {
        vm.broadcast();
         new TUINPool();
    }
}
<<<<<<< HEAD
=======




>>>>>>> 3c57862716ae1d8cae8320844151d50cb858ae71
