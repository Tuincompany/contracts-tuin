// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TUIN.sol";

contract TUINTest is Test {
    TUIN public tuin;
    mintCase[] public mintCases;

    address public poolContract = address(0x9809);
    address public owner = address(0x980ac9);

    struct mintCase {
        address account;
        uint256 amount;
        bool isEth;
    }

    function setUp() public {
        tuin = new TUIN(poolContract, true);
    }

    function testSimpleMint() public {
        tuin.mint(address(0x98), 10, true);
        assertEq(tuin.totalSupply(), 10);
        tuin.burn(address(0x98), 10, true);
        assertEq(tuin.totalSupply(), 0);
    }
    
    function testMintMoreThanETHTS() public {
        tuin.mint(address(0x98), 6000000000 * 1e18, true);
        assertEq(tuin.totalSupply(), 6000000000 * 1e18);
        tuin.burn(address(0x98), 6000000000 * 1e18, true);
        assertEq(tuin.totalSupply(), 0);
    }


    // function testSimpleFuzzMint(address user, uint256 amount, bool isEth) public {
    //     tuin.mint(user, amount, isEth);
    //     assertEq(tuin.totalSupply(), amount);
    //     tuin.burn(user, amount, isEth);
    //     assertEq(tuin.totalSupply(), 0);
    // }

    // @dev to do structured simulated tests
    // function testMintCase() public {
    //     assertEq(tuin.totalSupply(), 0);
    //           mintCases.push(mintCase(address(0x90), 10, false));
    // }

 


}
