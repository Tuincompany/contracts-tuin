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

        uint256 acceptedOut = ( amountIn * 75 ) /  100;
        assertEq(amountOut, acceptedOut);
    }

    /// @dev case to handle 1 usdt to 1000 tuin tokens
    function testExchangeRate1usdtTo1000tuintokens(uint256 amountIn, uint256 rate) public {
        amountIn = bound(amountIn, 1, 1e18); // because amount must not be zero
        rate     = bound(rate, 1, 500000000000); // because rate must not be zero
        tuinPool.setExchangeRate(rate);
        usdc.approve(address(tuinPool), amountIn);
        tuinPool.setAcceptedToken1(address(usdc));
        (uint256 amountOut,) = tuinPool.swapIn(amountIn, address(usdc), address(tuin));

        uint256 acceptedOut = ( amountIn * rate ) /  100;
        emit log_uint(acceptedOut);
        assertEq(amountOut, acceptedOut);        
    }

    /// @dev deposit potential profit into pools 
    function testDepositYield(uint256 amount2Deposit) public {
        amount2Deposit = bound(amount2Deposit, 1, 1e18);
        usdc.approve(address(tuinPool), amount2Deposit);
        tuinPool.depositYield(address(usdc), amount2Deposit);
    }

    /// @dev redeem 
    // function testRedeem(uint256 amountIn, uint256 rate, uint256 amount2Deposit, uint256 amountIn2) public {
    //     amount2Deposit = bound(amount2Deposit, 1, 1e18);
    //     // user has to first swap in 
    //     amountIn = bound(amountIn, 1, 1e18); // because amount must not be zero
    //     rate     = bound(rate, 1, 500000000000); // because rate must not be zero
    //     tuinPool.setExchangeRate(rate);
    //     usdc.approve(address(tuinPool), amountIn);
    //     tuinPool.setAcceptedToken1(address(usdc));
        
    //     (uint256 amountOut,) = tuinPool.swapIn(amountIn, address(usdc), address(tuin));
    //     uint256 acceptedOut = ( amountIn * rate ) /  100;
    //     assertEq(amountOut, acceptedOut);

    //     usdc.approve(address(tuinPool), amount2Deposit);
    //     tuinPool.approveYield(true);
    //     tuinPool.depositYield(address(usdc), amount2Deposit);

    //     uint256 userBalanceAtToken = tuin.balanceOf(msg.sender);
    //     assertEq(userBalanceAtToken, acceptedOut);
    //     amountIn2 = bound(amountIn2, 0, userBalanceAtToken);
       
    //     tuin.approve(address(tuinPool), amountIn2);
    //     tuinPool.redeem(amountIn2, address(tuin), address(usdc), true);
    // }
}