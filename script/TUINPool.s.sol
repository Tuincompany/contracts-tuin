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


/**
 forge script script/TUINPool.s.sol --rpc-url https://opt-goerli.g.alchemy.com/v2/xFsPGgJdzMjp3FS3kN69Af1REy-18yec --private-key $PRIVATE_KEY --broadcast
*/

