// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TUIN.sol";

contract TUINTest is Test {
    TUIN public tuin;
    
    mintCase[] public mintCases;

    address public poolContract = address(0x9809);
    address public owner = address(0x9809ac);

    struct mintCase {
        address account;
        uint256 amount;
        bool isEth;
    }

    function setUp() public {
        tuin = new TUIN(poolContract, false);
    }

    function testSimpleMint() public {
        tuin.mint(address(0x98), 10, false);
        assertEq(tuin.totalSupply(), 10);
        tuin.burn(address(0x98), 10, false);
        assertEq(tuin.totalSupply(), 0);
    }

    function testMintMoreThanBSCTS() public {
        tuin.mint(address(0x98), 6000000000 * 1e18, false);
        assertEq(tuin.totalSupply(), 6000000000 * 1e18);
        tuin.burn(address(0x98), 6000000000 * 1e18, false);
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
