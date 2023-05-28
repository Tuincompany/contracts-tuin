// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./TUIN.sol";
import { IERC20 } from "../interface/IERC20.sol";
       
/**
 * @title TUINPool is an Interest-bearing ERC20-like pool for TUIN Payments.
 * @dev   Implementation Tuin Pool v1. Tuin pool backs Tuin Token and sets collateralization ratio.
 *        Initially the flow of transactions starts at TUIN Token contract which mints TUIN Token to 
 *        TUINPool.
 *  
 *
 *        TUIN Balances represents a holder's share in the total amount of yield derived by TUIN Payments.
 *        Tuin balances are transferable and hence redeemable by the current holder. Each Holders yield is 
 *        calculated with the eq:
 *
 *        (   token_amount    *    total_yield_derived() )   /   total_token_amount
 *
 *
 *        token_amount:          the amount of token trying to retrieve yield.
 *        total_token_amount:    the total amount of tuin purchased.
 *        total_yield_derived(): amount of yield deposited
 *       
 *
 *        for example, assume that we have:
 *        total_yield_derived()    ->  100 usdc
 *        token_amount(user_one)   ->  20 Tuin Token
 *        token_amount(user_two)   ->  80 Tuin Token
 *
 *        Therefore: 
 *      
 *        total_token_amount           ->   100 Tuin Token
 *        total_redeemable( user_one ) -> ( 20 Tuin Token * 100 usdc ) / 100 Tuin Token --->>> 20 usdc
 *        total_redeemable( user_two ) -> ( 80 Tuin Token * 100 usdc ) / 100 Tuin Token --->>> 80 usdc
 *
 *        Profit in this case is determined per the initial amount of TUIN Purchased
 */

 contract TUINPool  {
    address public owner;
  
    address public acceptedToken1;
    address public acceptedToken2;
    address public acceptedToken3; 
    address public yieldToken;
    
    // for book-keeping purposes
    uint256 public amountDepositedacceptedToken1;
    uint256 public amountDepositedacceptedToken2;
    uint256 public amountDepositedacceptedToken3;

    uint256 public amountWithdrawnacceptedToken1;
    uint256 public amountWithdrawnacceptedToken2;
    uint256 public amountWithdrawnacceptedToken3;

    uint256 public amountYieldDepositedacceptedToken;

    string  public redeemableDate;

    bool    public isApproved;

    bool    public isPaused;

    uint256 public exchangeRateTuin;

    uint256 public exchangeRateUsd; 

    uint256 public immutable deploymentChainId; 
    
// 
    /// @dev functions marked with onlyOwner can be called by only owner 
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier Paused    {
        require(isPaused == false, "Err: contract is paused");
        _;
    }

    /**
     * @dev Constructor gives the contracts deployer initial ownership after which it can be set to 
     *      _surryWallet
     */
    constructor() {
        uint256 chainId;
        assembly {chainId := chainid()}
        deploymentChainId = chainId;
        owner = address(msg.sender);
    }

    /// @dev Set contract ownership, the initial ownership is set to the contract owner, and passed to _surrywallet
    function setOwner(address _surryWallet) onlyOwner() external {
        owner = _surryWallet;
    }


    /// @dev Set accpeted token 1 that can be used to purchase TUIN tokens from pool. 
    /// @dev The contract is a representation of single sided liquidity pool.
    function setAcceptedToken1(address _token1) onlyOwner() external {
        acceptedToken1 = _token1;
    }

    function setPaused(bool _isPaused) onlyOwner() external {
        isPaused = _isPaused;
    }
 
    /// @dev Set accpeted token 2 that can be used to purchase TUIN tokens from pool. 
    /// @dev The contract is a representation of single sided liquidity pool.
    function setAcceptedToken2(address _token2) onlyOwner() external {
        acceptedToken2 = _token2;
    }


    /// @dev Set accpeted token 3 that can be used to purchase TUIN tokens from pool. 
    /// @dev Initially accepted token 3 is set to a zero address in the constructor.
    /// @dev The contract is a representation of single sided liquidity pool.
    function setAcceptedToken3(address _token3) onlyOwner() external {
        acceptedToken3 = _token3;
    }

    function setYieldToken(address _yieldToken) onlyOwner() external {
        require( _yieldToken  ==  acceptedToken1  ||  _yieldToken  ==  acceptedToken2  || _yieldToken  ==  acceptedToken3, "Err: Not accepted token" );
        
        yieldToken = _yieldToken;
    }


    /// @dev Approve yield redemption for TUIN Token Holders.
    function approveYield(bool _isApproved) onlyOwner() external {
        isApproved = _isApproved;
    }


    /// @dev Announce the set date for yield redemption.
    function setRedeemableDate(string memory _date) onlyOwner() external {
        redeemableDate = _date;
    }

    /// @dev the exchange rate is as follows 
    ///      specify the amount of tuin equivalent to 1 usd 
    function setExchangeRateTuin(uint256 _rate) onlyOwner() external returns (bool success) {
        if (_rate == 0) revert("rate should be greater than 0");
       
        exchangeRateTuin = _rate;

        return true;
    }

    /// @dev the exchange rate is as follows 
    ///      specify the amount of tuin equivalent to 1 usd 
    function setExchangeRateUsd(uint256 _rate) onlyOwner() external returns (bool success) {
        if (_rate == 0) revert("rate should be greater than 0");
       
        exchangeRateUsd = _rate;

        return true;
    }

    /// @dev Get the pool's balance of tokenIn
    /// @dev This function is gas optimized to avoid a redundant extcodesize check in addition to the returndatasize
    /// check
    function balanceTknIn(address _tokenIn) private view returns (uint256) {
        (bool success, bytes memory data) =
            _tokenIn.staticcall(abi.encodeWithSelector(IERC20.balanceOf.selector, address(this)));

        require(success && data.length >= 32);

        return abi.decode(data, (uint256));
    }

    function amountTuinOut(address _tokenIn, address _tokenOut, uint256 _amountIn) public view returns (uint256 _amountTuinOut) {
        (bool success0, bytes memory data0) =
            _tokenIn.staticcall(abi.encodeWithSelector(IERC20.decimals.selector));

        require(success0 && data0.length >= 32);

        uint256 decimalTokenIn = abi.decode(data0, (uint256));

        (bool success1, bytes memory data1) =
            _tokenOut.staticcall(abi.encodeWithSelector(IERC20.decimals.selector));

        require(success1 && data1.length >= 32);

        uint256 decimalTokenOut = abi.decode(data1, (uint256));

        uint256 scale;

        // scale down
        if (decimalTokenIn > decimalTokenOut) {
            scale = decimalTokenIn - decimalTokenOut;
            _amountTuinOut = _amountIn * exchangeRateTuin / 10 ** scale;
        }

        // scale up
        scale = decimalTokenOut - decimalTokenIn;

        _amountTuinOut = scale == 0 ? _amountIn * exchangeRateTuin : _amountIn * exchangeRateTuin * 10 ** scale;
    }

    function scaleYieldTo18(address _tokenIn, uint256 _amountIn) public view returns (uint256) {
        (bool success0, bytes memory data0) =
            _tokenIn.staticcall(abi.encodeWithSelector(IERC20.decimals.selector));

        require(success0 && data0.length >= 32);

        uint256 decimalTokenIn = abi.decode(data0, (uint256));

        uint256 scale;

        // we want the token to  be scaled to 18.

        // scale down
        if (decimalTokenIn > 18) {
            scale = decimalTokenIn - uint256(18);

            return _amountIn / 10 ** scale;
        }

        // scale up
        scale = uint256(18) - decimalTokenIn;

        

        return ( scale == 0 ) ? _amountIn : _amountIn * 10 ** scale;
    }

    // It takes in a token address and an 18 decimal amount, and scales the 18 decimal amount to the 
    // token addresses decimal
    function scaleYieldToDecimal(address _tokenIn, uint256 _amountIn) public view returns (uint256) {
        (bool success0, bytes memory data0) =
            _tokenIn.staticcall(abi.encodeWithSelector(IERC20.decimals.selector));

        require(success0 && data0.length >= 32);

        uint256 decimalTokenIn = abi.decode(data0, (uint256));

        uint256 scale;

        // scale up
        if (decimalTokenIn > 18) {
            scale = decimalTokenIn - uint256(18);

            return _amountIn * exchangeRateUsd * 10 ** scale;
        }

        // scale down
        scale = uint256(18) - decimalTokenIn;

        return ( scale == 0 ) ? _amountIn * exchangeRateUsd : (_amountIn * exchangeRateUsd) / (10 ** scale);
    }

    function recordAmountDepositedacceptedToken(address _tokenIn, uint256 _amountIn) private {
        if ( _tokenIn  ==  acceptedToken1 )  amountDepositedacceptedToken1  += _amountIn;

        if ( _tokenIn  ==  acceptedToken2 )  amountDepositedacceptedToken2  += _amountIn;

        if ( _tokenIn  ==  acceptedToken3 )  amountDepositedacceptedToken3  += _amountIn;
    }

    function recordamountWithdrawnacceptedToken(address _tokenIn, uint256 _amountIn) private {
        if ( _tokenIn  ==  acceptedToken1 )  amountWithdrawnacceptedToken1 += _amountIn;

        if ( _tokenIn  ==  acceptedToken2 )  amountWithdrawnacceptedToken2  += _amountIn;

        if ( _tokenIn  ==  acceptedToken3 )  amountWithdrawnacceptedToken3  += _amountIn;
    }

    // yield token has to be one of the deposited yield tokens
    function recordamountYieldDepositedacceptedToken(address _tokenIn, uint256 _amountIn) private {
        _amountIn = scaleYieldTo18(_tokenIn, _amountIn);
        
        // tokens are added with 18 decimals
        amountYieldDepositedacceptedToken  += _amountIn;
    }

    // tests swapIn line by line
    // checkSwapInTokenEqAcceptedTkn
    function swapIn(uint256 _amountIn, address _tokenIn, address _tokenOut) Paused() external returns (bool)  {
        require( _amountIn  >  0, "ERR: _amountIn is 0" );

        require( _tokenIn  ==  acceptedToken1  ||  _tokenIn  ==  acceptedToken2  ||  _tokenIn  ==  acceptedToken3, "ERR: Not accepted token" );

        require( acceptedToken1  !=  address(0)  ||  acceptedToken2  !=  address(0)  ||  acceptedToken3  !=  address(0),  "ERR: Accepted tokens not set" );

        require( _tokenIn  !=  address(0) ,  "ERR: TokenIn address(0)" );

        // balance of tokenIn held by this contract
        uint256 balanceBefore = balanceTknIn(_tokenIn);

        // user transfer to this contract
        (bool success1, bytes memory data1) = _tokenIn.call(abi.encodeWithSelector(IERC20.transferFrom.selector, msg.sender, address(this), _amountIn));

        require( success1  &&  data1.length  >=  32, "Err: Couldn't TransferFrom" );

        // balance of tokenIn held by this contract
        uint256 balanceAfter = balanceTknIn(_tokenIn);

        // balance of tokenIn held by this contract after
        require( balanceBefore  +  _amountIn  >=  balanceAfter, "Err: Contracts balance not Increased" );
 
        if ( exchangeRateTuin == 0 ) revert("Err: exchange rate not set");

        uint256 _amountOut = amountTuinOut(_tokenIn, _tokenOut,_amountIn);

        require( tuinHeld(_tokenOut) >= _amountOut, "Err: Tuin Left is Less" );

        // transfer to user
        (bool success2, bytes memory data2) = address(_tokenOut).call(abi.encodeWithSelector(IERC20.transfer.selector, address(msg.sender), _amountOut));

        require( success2  &&  data2.length  >=  32, "Err: Couldn't Transfer Out" );

        recordAmountDepositedacceptedToken(_tokenIn, _amountIn);

        return true;
    }

    function tuinHeld(address tuinToken) public view returns (uint256 amountHeld) {
        (bool success, bytes memory data) = tuinToken.staticcall(
            abi.encodeWithSelector(IERC20.balanceOf.selector, address(this))
        );
        
        require( success  &&  data.length  >=  32, "Err: Couldn't get Tuin held" );

        amountHeld = abi.decode(data, (uint256));
    }

    // withdraws specified amount of Deposited accepted token
    function withdrawAcceptedToken(address _tokenIn, address _to, uint256 _amountOut) onlyOwner() public {
        (bool success, bytes memory data) = address(_tokenIn).call(abi.encodeWithSelector(IERC20.transfer.selector, _to, _amountOut));

        require( success  &&  data.length  >=  32, "Err: Couldn't withdraw accepted token held" );

        recordamountWithdrawnacceptedToken(_tokenIn, _amountOut);
    }

    // withdraws balance amount of Deposited accepted token
    function withdrawBalanceAcceptedToken(address _tokenIn, address _to) onlyOwner() external {
        uint256 _amountOut = balanceTknIn(_tokenIn);

        withdrawAcceptedToken(_tokenIn, _to, _amountOut);
    }

    function depositYieldToken(address _tokenIn, uint256 _amountIn) onlyOwner() external {
        require( _tokenIn  ==  acceptedToken1  ||  _tokenIn  ==  acceptedToken2  ||  _tokenIn  ==  acceptedToken3, "Err: Not accepted token" );

        require( _tokenIn  !=  address(0) ,  "Err: TokenIn address(0)" );

        (bool success, bytes memory data) = address(_tokenIn).call(abi.encodeWithSelector(IERC20.transferFrom.selector, msg.sender, address(this), _amountIn));

        require( success  &&  data.length  >=  32, "Err: Couldn't deposit accepted token" );

        recordamountYieldDepositedacceptedToken(_tokenIn, _amountIn);
    }

    // Redeem or swap out TUIN to get any of the deposited tokens
    // A different contract can handle redemption, at the point of redemption
    function redeem(uint256 _amountIn, address _tuinToken, address _yieldAddress) Paused() external {
        require( _amountIn != 0, "Err: cannot redeem zero amount");

        require( _yieldAddress  !=  address(0),  "Err: yield not set" );

        require( _yieldAddress  ==  acceptedToken1  ||  _yieldAddress  ==  acceptedToken2  ||  _yieldAddress  ==  acceptedToken3, "Err: Not accepted token" );

        require( isApproved     !=  false, "Err: still generating yield, check back" );
    
        // balance of tokenIn held by this contract
        uint256 balanceBefore = balanceTknIn(_tuinToken);

        // user transfer to this contract
        (bool success1, bytes memory data1) = _tuinToken.call(abi.encodeWithSelector(IERC20.transferFrom.selector, msg.sender, address(this), _amountIn));

        require( success1  &&  data1.length  >=  32, "Err: Couldn't TransferFrom" );

        // balance of tokenIn held by this contract
        uint256 balanceAfter = balanceTknIn(_tuinToken);

        // balance of tuin token held by this contract after increases
        require( balanceBefore  +  _amountIn  >=  balanceAfter, "Err: Contracts balance not Increased" );

        // burns tuin tokens
       (bool success2, bytes memory data2) = _tuinToken.call(abi.encodeWithSignature("burn(address,uint256)", address(this), _amountIn));

        require( success2  &&  data2.length  >=  32, "Err: Couldn't Burn" );

        if ( exchangeRateUsd == 0 ) revert("Err: exchange rate not set");

        uint256 _amountOut = scaleYieldToDecimal(_yieldAddress, _amountIn);

        require(yieldToken == _yieldAddress, "Err: not yield address");

        (bool success4, bytes memory data4) = _yieldAddress.call(abi.encodeWithSelector(IERC20.transfer.selector, address(msg.sender), _amountOut));

        require( success4  &&  data4.length  >=  32, "Err: TRANSFER_OUT_FAILED" );
    }
}















