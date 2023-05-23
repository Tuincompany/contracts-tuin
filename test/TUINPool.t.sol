// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TUINPool.sol";
import "../src/TUIN.sol";
import "../src/MockUSDC.sol";

contract TUINPoolTest is Test {

    TUIN     public tuin;
    TUINPool public tuinPool;
    MockUSDC public usdc;
    

    function setUp() public {
        tuinPool = new TUINPool();
        tuin     = new TUIN(address(tuinPool), true);
        usdc     = new MockUSDC();
    }

    /// @dev set mint address to 0x2ac to get test to pass
    function testUSDCMINT() public {
        // uint256 balance = 5000000000000000000000000 * 1e18;
        // uint256 usdcBalance = usdc.balanceOf(address(0x2ac));
        // assertEq(usdcBalance, balance);
    }

    /// @dev confirm that the pool contract controls the full mint of Tuin.
    function testTuinHeld() public {
        uint256 balanceAtToken   = tuin.balanceOf(address(tuinPool));
        uint256 balanceAtPoolCtr = tuinPool.tuinHeld(address(tuin));
        assertEq(balanceAtToken, balanceAtPoolCtr);
    }

    /// @dev this is the pools buy in contract
    function testSwapIn() public {
        uint256 amountIn = 2e26;
        tuinPool.setExchangeRate(75);
        usdc.approve(address(tuinPool), amountIn);
        tuinPool.setAcceptedToken1(address(usdc));

        (uint256 amountOut,) = tuinPool.swapIn(amountIn, address(usdc), address(tuin));

        uint256 acceptedOut = ( amountIn * (100 + 75) ) /  100;
        assertEq(amountOut, acceptedOut);
    }

    /// @dev deposit potential profit into pools 
    function testDepositYield() public {
        usdc.approve(address(tuinPool), 100e18);
        tuinPool.depositYield(address(usdc), 100e18);
    }

    /// @dev redeem 
    function testRedeem() public {
        // user has to first swap in 
        uint256 amountIn = 2e26;
        tuinPool.setExchangeRate(75);
        usdc.approve(address(tuinPool), amountIn);
        tuinPool.setAcceptedToken1(address(usdc));
        
        (uint256 amountOut,) = tuinPool.swapIn(amountIn, address(usdc), address(tuin));
        uint256 acceptedOut = ( amountIn * (100 + 75) ) /  100;
        assertEq(amountOut, acceptedOut);

        usdc.approve(address(tuinPool), 100e30);
        tuinPool.approveYield(true);
        tuinPool.depositYield(address(usdc), 100e30);

        uint256 userBalanceAtToken   = tuin.balanceOf(msg.sender);
        uint256 amountIn2 = amountOut - 35e16;
        if (amountIn2 <= userBalanceAtToken) revert ("amount in has to be within the boundary amount held by a user");

        tuin.approve(address(tuinPool), amountIn2);
        tuinPool.redeem(amountIn2, address(tuin), address(usdc), true);
    }
}