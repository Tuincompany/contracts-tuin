// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SURRYWallet.sol";
import "../src/TUINPool.sol";
import "../src/TUIN.sol";
import "../src/MockUSDC.sol";

contract SURRYWalletTest is Test {

    SURRYWallet public wallet;
    TUINPool    public pool;
    TUIN        public tuin;
    MockUSDC public usdc;

    function setUp() public {
        wallet = new SURRYWallet();
        pool   = new TUINPool();
        tuin   = new TUIN(address(pool), true);
        usdc     = new MockUSDC();
    }

    /// @dev pass ownership from contract deployer to specified address
    function testPassOwnership() public {
        wallet.setOwner(address(0x2a));
        assertEq(wallet.owner(), address(0x2a));
    }

    /// @dev set New Tuin Owner
    function testSetTuinOwner() public {
        tuin.setOwner(address(wallet));
        assertEq(tuin.owner(), address(wallet));
        wallet.setOwner(address(0x2a));
        vm.prank(address(0x2a));
        // set tuin owner to a wallet
        wallet.setTuinOwner(address(tuin), address(0x2a));
        assertEq(tuin.owner(), address(0x2a));
    }

    /// @dev set New Tuin Owner
    function testSetTuinPoolOwner() public {
        pool.setOwner(address(wallet));
        assertEq(pool.owner(), address(wallet));
    }

 

    /// @dev fuzz test networks and test new supply
    function testSetNewSupply(bool isEth) public {
         tuin.setOwner(address(wallet));
         assertEq(tuin.owner(), address(wallet));
         wallet.setNewSupply(address(tuin), 10000000000e18, isEth);

         if (isEth) {
            assertEq(tuin.maxsupply_on_eth(), 10000000000 * 1e18);
         } else {
            assertEq(tuin.maxsupply_on_bsc(), 10000000000 * 1e18);
         }
    }

    function testNewMint(bool isEth) public {
         tuin.setOwner(address(wallet));
         assertEq(tuin.owner(), address(wallet));
         wallet.setNewSupply(address(tuin), 10000000000e18, isEth);

         if (isEth) {
            assertEq(tuin.maxsupply_on_eth(), 10000000000 * 1e18);
         } else {
            assertEq(tuin.maxsupply_on_bsc(), 10000000000 * 1e18);
         }
         wallet.newMint(address(tuin), address(0x38a), 5000e18, isEth);

         assertEq(tuin.balanceOf(address(0x38a)), 5000e18);
    }

    /// @dev test set accepted token
    function testSetAcceptedToken() public {
        pool.setOwner(address(wallet));
        assertEq(pool.owner(), address(wallet));
        bool success = wallet.setAcceptedToken(address(pool), address(usdc), 1);
        assertEq(success, true);
    }

    /// @dev test set yield address
    function testSetYieldAddress() public {
        pool.setOwner(address(wallet));
        assertEq(pool.owner(), address(wallet));
        bool success = wallet.setYieldAddress(address(pool), address(usdc));
        assertEq(success, true);
    }

    /// @dev test set yield address
    function testSetApproveYield() public {
        pool.setOwner(address(wallet));
        assertEq(pool.owner(), address(wallet));
        bool success = wallet.setApproveYield(address(pool), true);
        assertEq(success, true);
    }

    /// @dev test set redeemable date 
    function testSetRedeemableDate() public {
        pool.setOwner(address(wallet));
        assertEq(pool.owner(), address(wallet));
        bool success = wallet.setRedeemableDate(address(pool), "2023 May 8th");
        assertEq(success, true);
    }

    /// @dev test set redeemable date 
    function testSetExchangeRate() public {
        pool.setOwner(address(wallet));
        assertEq(pool.owner(), address(wallet));
        bool success = wallet.setExchangeRate(address(pool), 25);
        assertEq(success, true);
    }

    function testPutDepositYield() public {
        pool.setOwner(address(wallet));
        assertEq(pool.owner(), address(wallet));
        usdc.approve(address(wallet), 300002030e18);
        bool success = wallet.putDepositYield(address(pool), address(usdc), 300002030e18);
        assertEq(success, true);
    }

    function withdrawTkn() public {
        
    }
}