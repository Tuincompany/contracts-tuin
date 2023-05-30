// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/TUINController.sol";

import "src/TUINPool.sol";
import "../src/TUIN.sol";
import "src/MockUSDC.sol";
// import "../src/TUINController.sol";

contract TUINControllerTest is Test {

    TUIN     public tuin;
    TUINPool public tuinPool;
    MockUSDC public usdc;
    TUINController public tuinController;

    function setUp() public {
        tuinPool = new TUINPool();
        tuin     = new TUIN(address(tuinPool));
        usdc     = new MockUSDC();
        tuinController = new TUINController();
    }

    // the first three lines of the contract handles ownership of the contract
    // function testOwnerOfController() public {
    //     assertEq(tuinController.owner(), address(0x2Ac));
    // }

    // check to see if you can set ownership of the contract 
    // function testSetOwnership(address _newOwner) public {
    //     tuinController.setOwner(_newOwner);
    //     //vm.prank(_newOwner);

    //     assertEq(tuinController.owner(), _newOwner);
    // }
    // with this i have tested the ownership of this contract 

//     function testSetTuinOwner() public {
//         // pass owner ship to controller
//         tuin.setOwner(address(tuinController));

//         // should be called when passing ownership of controller 
//         // if called calls to this contracts would not be able to succeed with the pool and tha tuin contract
//         // i.e. a new controller should be deployed 
//         // tuinController.setTuinOwner(address(tuin), address(0x2Ac));

//         // pass tuin controller owner to 0x2Ac
//         tuinController.setOwner(address(0x2Ac));

//         // call 
//         vm.startPrank(address(0x2Ac));

//         tuinController.setTuinPoolAddress(address(tuin), address(0x000a));

//         vm.stopPrank();

//         assertEq(tuin.pool(), address(0x000a));
//    }

    // function testNewMint() public {
    //     // pass owner ship to controller
    //     tuin.setOwner(address(tuinController));

    //     // pass tuin controller owner to 0x2Ac
    //     tuinController.setOwner(address(0x2Ac));

    //     vm.startPrank(address(0x2Ac));
        
    //     // we first have to increase the chain supply
    //     // the new chain supply most be whole and greater than the previous chain supply
    //     tuinController.setNewSupply(address(tuin), 5000000009 * 1e18);
    //     // the msg.sender is the contract
    //     bool ok = tuinController.newMint(address(tuin), address(0x9BF), 8e18);
    //     assertEq(ok, true);
    //     vm.stopPrank();
    // }

    // function testSetTuinPoolOwner() public {
    //     tuinPool.setOwner(address(tuinController));

    //     tuinController.setOwner(address(0x2Ac));

    //     vm.startPrank(address(0x2Ac));

    //     bool ok = tuinController.setTUINPoolOwner(address(tuinPool), address(0x2Ac));

    //     vm.stopPrank();

    //     assertEq(ok, true);
    // }

    // function testSetAcceptedToken() public {
    //     tuinPool.setOwner(address(tuinController));

    //     tuinController.setOwner(address(0x2Ac));

    //     vm.startPrank(address(0x2Ac));

    //     bool ok = tuinController.setAcceptedToken(address(tuinPool), address(usdc), 2);

    //     vm.stopPrank();

    //     assertEq(ok, true);
    // }

    // function testSetPaused() public {
    //     tuinPool.setOwner(address(tuinController));

    //     tuinController.setOwner(address(0x2Ac));

    //     vm.startPrank(address(0x2Ac));

    //     bool ok = tuinController.setPaused(address(tuinPool), true);

    //     vm.stopPrank();

    //     assertEq(ok, true);
    // }
    // function testSetYieldToken() public {
    //     tuinPool.setOwner(address(tuinController));

    //     tuinController.setOwner(address(0x2Ac));

    //     vm.startPrank(address(0x2Ac));

    //     bool ok = tuinController.setYieldToken(address(tuinPool), true);

    //     vm.stopPrank();

    //     assertEq(ok, true);
    // }
    // function testSetApproveYield() public {
    //     tuinPool.setOwner(address(tuinController));

    //     tuinController.setOwner(address(0x2Ac));

    //     vm.startPrank(address(0x2Ac));

    //     bool ok = tuinController.setApproveYield(address(tuinPool), true);

    //     vm.stopPrank();

    //     // check @ pool contract
    //     assertEq(tuinPool.isApproved(), true);

    //     assertEq(ok, true);
    // }

    // function testSetRedeemableDate() public {
    //     tuinPool.setOwner(address(tuinController));

    //     tuinController.setOwner(address(0x2Ac));

    //     vm.startPrank(address(0x2Ac));

    //     bool ok = tuinController.setRedeemableDate(address(tuinPool), "29th may");

    //     vm.stopPrank();

    //     assertEq(ok, true);
    // }
    // function testSetRedeemableDate() public {
    //     tuinPool.setOwner(address(tuinController));

    //     tuinController.setOwner(address(0x2Ac));

    //     vm.startPrank(address(0x2Ac));

    //     bool ok = tuinController.setRedeemableDate(address(tuinPool), "29th may");

    //     vm.stopPrank();

    //     assertEq(ok, true);
    // }

    // function testSetExchangeRate() public {
    //     tuinPool.setOwner(address(tuinController));

    //     tuinController.setOwner(address(0x2Ac));

    //     vm.startPrank(address(0x2Ac));

    //     bool ok = tuinController.setExchangeRateTuin(address(tuinPool), 1000);


    //     assertEq(ok, true);

    //     assertEq(tuinPool.exchangeRateTuin(), 1000);

    //     ok = tuinController.setExchangeRateUsd(address(tuinPool), 1000);

    //     vm.stopPrank();

    //     assertEq(ok, true);

    //     assertEq(tuinPool.exchangeRateUsd(), 1000);
    // }


    function testDepositYieldAndWithdraw(uint256 _amountIn) public {
        // set ownership to controller contract
        tuinPool.setOwner(address(tuinController));

        tuin.setOwner(address(tuinController));

        // pass ownership of controller contract to e o a
        // in this case surry e o a
        tuinController.setOwner(address(0x8296CE3497A9b8e6aB6F48d36551eeF42a7b0E48));

     
        // using 0x8296CE3497A9b8e6aB6F48d36551eeF42a7b0E48
        // set rate and accepted token
        vm.startPrank(address(0x8296CE3497A9b8e6aB6F48d36551eeF42a7b0E48));
        uint256 _rate = 1000;

        // should be set by owner
        // address _yieldAddress = address(usdc);

        // set the rate i.e. 1 usd == 1000 tuin tokens
        tuinController.setExchangeRateTuin(address(tuinPool), _rate);

        // set the accepted deposit so users can swap
        tuinController.setAcceptedToken(address(tuinPool), address(usdc), 2);
        tuinController.setYieldToken(address(tuinPool), address(usdc));

        vm.stopPrank();



        // swap 
        // in other for a user to swap
        // acceoted token must be set by the owner
        // rate must be set by the owner
        vm.startPrank(address(0x2Ac));

        uint256 usdcAmountIn = 10e6;

        usdc.approve(address(tuinPool), usdcAmountIn);

        tuinPool.swapIn(usdcAmountIn, address(usdc), address(tuin));

        // get amount out
        uint256 _amountTuinOut = tuinPool.amountTuinOut(address(usdc), address(tuin), usdcAmountIn);

        assertEq( _amountTuinOut, 10000e18 );

        vm.stopPrank();

        assertEq(usdc.balanceOf(address(tuinPool)), 10e6);
        // withdraw amount swapped in
        // that is allowing surry withdraw
        vm.startPrank(address(0x8296CE3497A9b8e6aB6F48d36551eeF42a7b0E48));

        tuinController.withdraw(address(tuinPool), address(usdc), address(0x8296CE3497A9b8e6aB6F48d36551eeF42a7b0E48), tuinPool.balanceTknIn(address(usdc)));

        usdc.approve(address(tuinController), 10e6);



        tuinController.putDepositYield(address(tuinPool), address(usdc), 10e6);

        tuinController.withdraw(address(tuinPool), address(usdc), address(0x8296CE3497A9b8e6aB6F48d36551eeF42a7b0E48), tuinPool.balanceTknIn(address(usdc)));


        vm.stopPrank();

        assertEq(usdc.balanceOf(address(0x8296CE3497A9b8e6aB6F48d36551eeF42a7b0E48)), 10e6);

        // assertEq(usdc.balanceOf(address(0x7aD)), 5e6);



        // amount in here would be for redeem
        // _amountIn = bound(_amountIn, 1e6, 5000000000e6);


    }




       // vm.startPrank(address(0x2Ac));

        // bool ok = tuinController.setExchangeRateTuin(address(tuinPool), 1000);


        // assertEq(ok, true);

        // assertEq(tuinPool.exchangeRateTuin(), 1000);

        // ok = tuinController.setExchangeRateUsd(address(tuinPool), 1000);

        // vm.stopPrank();

        // assertEq(ok, true);

        // assertEq(tuinPool.exchangeRateUsd(), 1000);



    // function testRedeem(uint256 _amountIn) public {
    //     _amountIn = bound(_amountIn, 1e6, 5000000000e6);

        // uint256 _rate = 1000;

        // should be set by owner
        // address _yieldAddress = address(usdc);

        // _amountIn = 1000000e6;
        
        // we set the accepted token to non erc20 address
    //     usdc.approve(address(tuinPool), _amountIn);  
   
    //     // SET TOKEN DEPOSIT 
    //     tuinPool.setAcceptedToken3(_yieldAddress);

    //     // SET TOKEN REDEMPTION
    //     tuinPool.setYieldToken(address(usdc));

    //     // deposit yield for a user
    //     tuinPool.depositYieldToken(address(usdc), _amountIn);

    //     tuinPool.setExchangeRateTuin(_rate);
    //     tuinPool.setExchangeRateUsd(50);

    //     tuinPool.approveYield(true);

    //     // start prank a user should swapin

    //     vm.startPrank(address(0x2Ac));

    //     uint256 usdcAmountIn = 10e6;

    //     usdc.approve(address(tuinPool), usdcAmountIn);

    //     tuinPool.swapIn(usdcAmountIn, address(usdc), address(tuin));

    //     // get amount out
    //     uint256 _amountTuinOut = tuinPool.amountTuinOut(address(usdc), address(tuin), usdcAmountIn);

    //     assertEq( _amountTuinOut, 10000e18 );

    //     tuin.approve(address(tuinPool), _amountTuinOut);
    //     // call redeem function
    //     tuinPool.redeem(_amountTuinOut, address(tuin), address(usdc));

    //     uint256 yield = usdc.balanceOf(address(0x2Ac));
    //     assertEq(yield, 500000e6);

    //     vm.stopPrank();
    // }

   
     
    
}