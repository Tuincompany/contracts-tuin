// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/TUINPool.sol";
import "../src/TUIN.sol";
import "../src/MockUSDC.sol";
import "../src/TUINController.sol";

contract TUINPoolTest is Test {

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

    // checkSwapInAmountInNotZero 
    // function checkSwapInAmountInNotZero(uint256 _amountIn) external pure returns (bool)  {
    //     require( _amountIn  >  0, "ERR: _amountIn is 0" );
    //     return true;
    // }

    // case 2:  require( _tokenIn  ==  acceptedToken1  ||  _tokenIn  ==  acceptedToken2  ||  _tokenIn  ==  acceptedToken3, "ERR: Not accepted token" );
    // case 3:  require( acceptedToken1  !=  address(0)  ||  acceptedToken2  !=  address(0)  ||  acceptedToken3  !=  address(0),  "ERR: Accepted tokens not set" );
    // case 4:  require( _tokenIn  !=  address(0) ,  "ERR: TokenIn address(0)" );
    // case 5:  can't get balance of non erc20 if byte is < 32
    // case 6:  can't transfer erc20 if byte is < 32
    // case 7:  contracts balance not increased
    // case 8:  check if the exchange rate was set, if ( exchangeRate == 0 ) revert("Err: exchange rate not set");

    // Test Cases
    // Case 1: amountIn == zero, 0 i.e. cannot be less than zero or negative number, negative checks are handles with uint256
    // Case 2: tokenIn  == acceptedTkn, i.e. the tokenIn is an accepted token of this contract
    // Case 3: accepted Token  != address(0), i.e. accepted token not equal to zero address
    // case 4: _tokenIn  !=  address(0) i.e. the token input by the user cannot be zero
    // case 5: (bool success, bytes memory data) = _tokenIn.staticcall(abi.encodeWithSelector(IERC20.balanceOf.selector, address(this)));
    //         require( success  &&  data.length  >=  32, "Err: Couldn't get balance" );
    // case 6: (bool success1, bytes memory data1) = _tokenIn.call(abi.encodeWithSelector(IERC20.transferFrom.selector, msg.sender, address(this), _amountIn));
    //          require( success1  &&  data1.length  >=  32, "Err: Couldn't TransferFrom" );
    // case 7: repeat case 5, to ensure the contract balance has been increased
    //          require( balanceBefore  +  _amountIn  >=  balanceAfter, "Err: Contracts balance not Increased" );
    // case 8: check if the exchange rate was set
    // case 9: check if you can get the right amount out of tuin token, on usdc six decimal
    // case 10: the amount of token tuin held by the contract must be greater than or equal  to the amount out
    // case 11: breaking 10



    /** CASE 1 */
    // function testCheckAmountInNotZero1(uint256 _amountIn) public {
    //     _amountIn = bound(_amountIn, 0, 0);
    //     bool success = tuinPool.checkSwapInAmountInNotZero(_amountIn);
    //     assertEq(true, success);
    // }

    // amount in as less than zero, a negative doesn't work
    // function testCheckAmountInNotZero2(uint256 _amountIn) public {
    //     _amountIn = bound(_amountIn, -36987, 0);
    //     bool success = tuinPool.checkSwapInAmountInNotZero(_amountIn);
    //     assertEq(true, success);
    // }

    /** CASE 2 */
    // check if the token being deposited is equal to the accepted token
    // would fail because accepted token wasn't set
    // function testCheckSwapInTokenEqAcceptedTknFails(uint256 _amountIn, address _tokenIn) public {
    //     _amountIn    = bound(_amountIn, 1, 5000000000); // concerns aren't made here since this has been previously tested
       
    //     bool success = tuinPool.checkSwapInTokenEqAcceptedTkn(_amountIn, _tokenIn);
        
    //     assertEq(true, success);
    // }

    // would pass if any of the accepted tokens was set
    // function testCheckSwapInTokenEqAcceptedTknPass(uint256 _amountIn, address _tokenIn) public {
    //     _amountIn    = bound(_amountIn, 1, 5000000000); // concerns aren't made here since this has been previously tested
       
    //     // alternated between set accepted token1 || token2 || token3 it passes
    //     // if this line of code is removed it fails
    //     tuinPool.setAcceptedToken3(_tokenIn);

    //     bool success = tuinPool.checkSwapInTokenEqAcceptedTkn(_amountIn, _tokenIn);
        
    //     assertEq(true, success);
    // }

    // check accepted token isn't zero address and hence not 
    // this check has nothing to do with the token in but every thing to do with the accepted token being set
    // function testCheckSwapInAcceptedTknNTEqZero(uint256 _amountIn) public {
    //     _amountIn    = bound(_amountIn, 1, 5000000000); // concerns aren't made here since this has been previously tested
       
    //     // we set the accepted token to zero address
    //     tuinPool.setAcceptedToken3(address(0));

    //     // we set tokenIn to zero address
    //     bool success = tuinPool.checkSwapInAcceptedTknNTEqZero(_amountIn, address(0));
        
    //     assertEq(true, success);
    // }

    // check that the token in is not a zero address only work if accepted token address not zero is off
    // function testCheckSwapInTknInNTEqZero(uint256 _amountIn) public {
    //     _amountIn    = bound(_amountIn, 1, 5000000000); // concerns aren't made here since this has been previously tested
       
    //     // we set the accepted token to zero address
    //     tuinPool.setAcceptedToken3(address(0));

    //     // we set tokenIn to zero address
    //     bool success = tuinPool.checkSwapInTknInNTEqZero(_amountIn, address(0));
        
    //     assertEq(true, success);
    // }

    // function testcheckSwapInTknNtErc20Fail(uint256 _amountIn) public {
    //     _amountIn    = bound(_amountIn, 1, 5000000000); // concerns aren't made here since this has been previously tested
    //     address _tokenIn = address(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF);
    //     // we set the accepted token to non erc20 address
                                            
    //     tuinPool.setAcceptedToken3(_tokenIn);
    //     // we set tokenIn to non erc20 address
    //     (bool success, ) = tuinPool.checkSwapInTknNtErc20(_amountIn, _tokenIn);
        
    //     assertEq(true, success);
    // }

    // USDT: 0xdAC17F958D2ee523a2206206994597C13D831ec7
    // USDC: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
    // BUSD: 0x4Fabb145d64652a948d72533023f6E7A623C7C53
    // success is not a true source of truth when calling the a contract
    // this would fail if bytes is < 32
    // function testcheckSwapInTknNtErc20FailUsdt(uint256 _amountIn) public {
    //     _amountIn    = bound(_amountIn, 1, 5000000000); // concerns aren't made here since this has been previously tested
    //     address _tokenIn = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    //     // we set the accepted token to non erc20 address
                                            
    //     tuinPool.setAcceptedToken3(_tokenIn);
    //     // we set tokenIn to non erc20 address
    //     ( bool success, uint256 balanceBefore ) = tuinPool.checkSwapInTknNtErc20(_amountIn, _tokenIn);
        
    //     assertEq(true, success);
    //     assertEq(balanceBefore, 1);
    // }

    // success is not a true source of truth when calling the a contract
    // this would fail if bytes is < 32
    // we further enforce that the contracts balance increase using balance before and balance check
    // function testcheckSwapInUSDCBalanceBefore(uint256 _amountIn) public {
    //     _amountIn = bound(_amountIn, 1, 5000000000e18); // concerns aren't made here since this has been previously tested
        
    //     address _tokenIn = address(usdc);
        
    //     // we set the accepted token to non erc20 address
    //     usdc.approve(address(tuinPool), _amountIn);             
        
    //     tuinPool.setAcceptedToken3(_tokenIn);

    //     // we set tokenIn to non erc20 address
    //     ( bool success, ) = tuinPool.checkSwapInUSDC(_amountIn, _tokenIn);
        
    //     assertEq(true, success);
    // }

    // // whether by setting or not setting exchange rate fails
    // function testcheckSwapInUSDCrateAsZeroFail(uint256 _amountIn) public {
    //     _amountIn = bound(_amountIn, 1, 5000000000e18); // concerns aren't made here since this has been previously tested
        
    //     address _tokenIn = address(usdc);
        
    //     // we set the accepted token to non erc20 address
    //     usdc.approve(address(tuinPool), _amountIn);             
        
    //     tuinPool.setAcceptedToken3(_tokenIn);
        
    //     // if set exchange rate to zero, func setExchangeRate errors
    //     // if not set swapIn errors
    //     // tuinPool.setExchangeRate(0);
    //     // we set tokenIn to non erc20 address
    //     ( bool success, ) = tuinPool.checkSwapInUSDC(_amountIn, _tokenIn);
        
    //     assertEq(true, success);
    // }

    // whether by setting or not setting exchange rate fails
    // various erc20 tokens have their various decimals which scale the token
    // the frontend handles this
    // this is a swap at decimal 18
    // function testcheckSwapInAmountOutatDecimal18(uint256 _amountIn, uint256 _rate) public {
    //     // amountIn is scaled by the front end or caller to 18 decimal places
    //     // example usdc
    //     _amountIn = bound(_amountIn, 1e6, 5000000000e6); // concerns aren't made here since this has been previously tested
    //     // scale It
    //     _amountIn *= 1e12;
    //     _rate = bound(_rate, 1, 5000000000e18);
    //     address _tokenIn = address(usdc);
        
    //     // we set the accepted token to non erc20 address
    //     usdc.approve(address(tuinPool), _amountIn);             
        
    //     tuinPool.setAcceptedToken3(_tokenIn);
        
    //     // if set exchange rate to zero, func setExchangeRate errors
    //     // if not set swapIn errors
    //     tuinPool.setExchangeRate(_rate);
    //     // we set tokenIn to non erc20 address
    //     ( bool success, uint256 amountOut ) = tuinPool.checkSwapInUSDC(_amountIn, _tokenIn, address(tuin));
        
    //     uint256 acceptedAmountOut = _amountIn * _rate;

    //     assertEq(true, success);
    //     assertEq(amountOut, acceptedAmountOut);

    // }

    // amountTuinOut gets the decimal of the tokenIn and tokenOut
    // if the difference between the two is 0 (we dont scale), otherwise scale by the difference
    // function testcheckamountTuinOut(uint256 _amountIn, uint256 _rate) public {
    //     // example usdc
    //     _amountIn = bound(_amountIn, 1e6, 5000000000e6); 
        
    //     _rate = bound(_rate, 1, 5000000000e18);
    //     address _tokenIn = address(usdc);
        
    //     // we set the accepted token to non erc20 address
    //     usdc.approve(address(tuinPool), _amountIn);             
        
    //     tuinPool.setAcceptedToken3(_tokenIn);
        
    //     // if set exchange rate to zero, func setExchangeRate errors
    //     // if not set swapIn errors
    //     tuinPool.setExchangeRate(_rate);
    //     // we set tokenIn to non erc20 address
    //     uint256 amountOut  = tuinPool.amountTuinOut(_tokenIn, address(tuin), _amountIn);
        
    //     // scale It
    //     _amountIn *= 1e12;
    //     uint256 acceptedAmountOut = _amountIn * _rate;  
    //     assertEq(amountOut, acceptedAmountOut);
    // }
    
    // a redo of the above but with more specificity
    // function testcheckamountTuinOut() public {
    //     // example usdc
    //     // if 1 usdc = 1000 tuin tokens (1000e18)
    //     // 0.5 usdc = 500 tuin tokens (500e18)
    //     uint256 _amountIn = 500000; // 0.5 usdc
        
    //     uint256 _rate = 1000;
    //     address _tokenIn = address(usdc);
        
    //     // we set the accepted token to non erc20 address
    //     usdc.approve(address(tuinPool), _amountIn);             
        
    //     tuinPool.setAcceptedToken3(_tokenIn);
        
    //     // if set exchange rate to zero, func setExchangeRate errors
    //     // if not set swapIn errors
    //     tuinPool.setExchangeRate(_rate);
    //     // we set tokenIn to non erc20 address
    //     uint256 amountOut  = tuinPool.amountTuinOut(_tokenIn, address(tuin), _amountIn);
        
    //     // scale It
    //     _amountIn *= 1e12;
    //     uint256 acceptedAmountOut = _amountIn * _rate;  
    //     assertEq(amountOut, acceptedAmountOut);
    // }

    // test tuin held works as it is supposed to
    // function testTuinHeld() public {
    //     uint256 _amountHeld = tuinPool.tuinHeld(address(tuin));
    //     assertEq(_amountHeld, 5000000000e18);
    // }

    // function testcheckSwapInUSDC() public {
    //     // example usdc
    //     // if 1 usdc = 1000 tuin tokens (1000e18)
    //     // 0.5 usdc = 500 tuin tokens (500e18)
    //     uint256 _amountIn = 5000000e6; // 0.5 usdc
        
    //     uint256 _rate = 1000;
    //     address _tokenIn = address(usdc);
        
    //     // we set the accepted token to non erc20 address
    //     usdc.approve(address(tuinPool), _amountIn);             
        
    //     tuinPool.setAcceptedToken3(_tokenIn);
        
    //     // if set exchange rate to zero, func setExchangeRate errors
    //     // if not set swapIn errors
    //     tuinPool.setExchangeRate(_rate);
    //     // we set tokenIn to non erc20 address
    //     ( bool success, uint256 amountOut )  = tuinPool.checkSwapInUSDC(_amountIn, _tokenIn, address(tuin));
        
    //     // scale It
    //     _amountIn *= 1e12;
    //     _amountIn += 1;
        
    //     uint256 acceptedAmountOut = _amountIn * _rate;  
    //     assertEq(amountOut, acceptedAmountOut);
    //     assertEq(success, true);
    // }
    // function testcheckSwapInUSDC() public {
    //     // example usdc
    //     // if 1 usdc = 1000 tuin tokens (1000e18)
    //     // 0.5 usdc = 500 tuin tokens (500e18)
    //     uint256 _amountIn = 500000e6; // 0.5 usdc
        
    //     uint256 _rate = 1000;
    //     address _tokenIn = address(usdc);
        
    //     // we set the accepted token to non erc20 address
    //     usdc.approve(address(tuinPool), _amountIn);             
        
    //     tuinPool.setAcceptedToken3(_tokenIn);
        
    //     // if set exchange rate to zero, func setExchangeRate errors
    //     // if not set swapIn errors
    //     tuinPool.setExchangeRate(_rate);
    //     // we set tokenIn to non erc20 address
    //     bool success = tuinPool.checkSwapInUSDC(_amountIn, _tokenIn, address(tuin));
        
    //     // scale It
    //     _amountIn *= 1e12;
        
    //     assertEq(success, true);
    // }
    // function testcheckWithdrawAcceptedToken() public {
    //     // example usdc
    //     // if 1 usdc = 1000 tuin tokens (1000e18)
    //     // 0.5 usdc = 500 tuin tokens (500e18)
    //     // i want to deposit as a user here
    //     // i want to withdraw as the owner here, prank is owner
    //     uint256 _amountIn = 500000e6; // 0.5 usdc
        
    //     uint256 _rate = 1000;
    //     address _tokenIn = address(usdc);
        
    //     // we set the accepted token to non erc20 address
    //     usdc.approve(address(tuinPool), _amountIn);             
        
    //     tuinPool.setAcceptedToken3(_tokenIn);
        
    //     // if set exchange rate to zero, func setExchangeRate errors
    //     // if not set swapIn errors
    //     tuinPool.setExchangeRate(_rate);
    //     // we set tokenIn to non erc20 address
    //     bool success = tuinPool.checkSwapInUSDC(_amountIn, _tokenIn, address(tuin));
    //     assertEq(success, true);
    //     // scale It
    //     _amountIn *= 1e12;

    //     tuinPool.setOwner(address(0x2Ac));
    //     vm.prank(address(0x2Ac));

    //     tuinPool.checkWithdrawAcceptedToken(_tokenIn, address(0x2Ac));

    //     uint256 ownerBalance = usdc.balanceOf(address(0x2Ac));

    //     assertEq(_amountIn / 1e12, ownerBalance);

        
    // }

    // function testcheckWithdrawAcceptedToken() public {
    //     // example usdc
    //     // if 1 usdc = 1000 tuin tokens (1000e18)
    //     // 0.5 usdc = 500 tuin tokens (500e18)
    //     // i want to deposit as a user here
    //     // i want to withdraw as the owner here, prank is owner
    //     uint256 _amountIn = 500000e6; // 0.5 usdc
        
    //     uint256 _rate = 1000;
    //     address _tokenIn = address(usdc);
        
    //     // we set the accepted token to non erc20 address
    //     usdc.approve(address(tuinPool), _amountIn);             
        
    //     tuinPool.setAcceptedToken3(_tokenIn);
        
    //     // if set exchange rate to zero, func setExchangeRate errors
    //     // if not set swapIn errors
    //     tuinPool.setExchangeRate(_rate);
    //     // we set tokenIn to non erc20 address
    //     bool success = tuinPool.swapIn(_amountIn, _tokenIn, address(tuin));
    //     assertEq(success, true);
    //     // scale It

    //     tuinPool.setOwner(address(0x2Ac));
    //     vm.prank(address(0x2Ac));

    //     tuinPool.withdrawAcceptedToken(_tokenIn, address(0x2Ac), _amountIn);

    //     uint256 ownerBalance = usdc.balanceOf(address(0x2Ac));

    //     assertEq(_amountIn, ownerBalance);   
    // }

    // function testcheckDepositYield() public {
    //     // example usdc
    //     // if 1 usdc = 1000 tuin tokens (1000e18)
    //     // 0.5 usdc = 500 tuin tokens (500e18)
    //     // i want to deposit as a user here
    //     // i want to withdraw as the owner here, prank is owner
    //     uint256 _amountIn = 500000e6; // 0.5 usdc
        
    //     uint256 _rate = 1000;
    //     address _tokenIn = address(usdc);
        
    //     // we set the accepted token to non erc20 address
    //     usdc.approve(address(tuinPool), _amountIn);             
        
    //     tuinPool.setAcceptedToken3(_tokenIn);
        
    //     // if set exchange rate to zero, func setExchangeRate errors
    //     // if not set swapIn errors
    //     tuinPool.setExchangeRate(_rate);
    //     // we set tokenIn to non erc20 address
    //     bool success = tuinPool.swapIn(_amountIn, _tokenIn, address(tuin));
    //     assertEq(success, true);
    //     // scale It
    //     assertEq(tuinPool.amountDepositedacceptedToken3(), _amountIn);
        

    //     tuinPool.setOwner(address(0x2Ac));
    //     vm.prank(address(0x2Ac));

    //     tuinPool.withdrawAcceptedToken(_tokenIn, address(0x2Ac), _amountIn);

    //     uint256 ownerBalance = usdc.balanceOf(address(0x2Ac));

    //     assertEq(_amountIn, ownerBalance);

    //     assertEq(tuinPool.amountWithdrawnacceptedToken3(), _amountIn);
   
    // }

    function testRedeem(uint256 _amountIn) public {
        _amountIn = bound(_amountIn, 1e6, 5000000000e6);

        uint256 _rate = 1000;

        // should be set by owner
        address _yieldAddress = address(usdc);

        _amountIn = 1000000e6;
        
        // we set the accepted token to non erc20 address
        usdc.approve(address(tuinPool), _amountIn);  
   
        tuinPool.setAcceptedToken3(_yieldAddress);
        tuinPool.setYieldToken(address(usdc));

        // deposit yield for a user
        tuinPool.depositYieldToken(address(usdc), _amountIn);

        tuinPool.setExchangeRateTuin(_rate);
        tuinPool.setExchangeRateUsd(50);

        tuinPool.approveYield(true);

        // start prank a user should swapin

        vm.startPrank(address(0x2Ac));

        uint256 usdcAmountIn = 10e6;

        usdc.approve(address(tuinPool), usdcAmountIn);

        tuinPool.swapIn(usdcAmountIn, address(usdc), address(tuin));

        // get amount out
        uint256 _amountTuinOut = tuinPool.amountTuinOut(address(usdc), address(tuin), usdcAmountIn);

        assertEq( _amountTuinOut, 10000e18 );

        tuin.approve(address(tuinPool), _amountTuinOut);
        // call redeem function
        tuinPool.redeem(_amountTuinOut, address(tuin), address(usdc));

        uint256 yield = usdc.balanceOf(address(0x2Ac));
        assertEq(yield, 500000e6);

        vm.stopPrank();
    }

    
  
 

 

    
}