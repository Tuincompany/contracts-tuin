// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import './TUIN.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";






       
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
    bool    public isApproved;
    address public owner;
    address public acceptedToken1;
    address public acceptedToken2;
    address public acceptedToken3;
    address public yieldAddress;
    uint256 public totalYieldDerived;  
    uint256 public exchangeRate;  
    uint256 public immutable deploymentChainId; 
    string  public redeemableDate;




    /// @dev functions marked with onlyOwner can be called by only owner 
    modifier onlyOwner {
        require(msg.sender == owner);
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
        acceptedToken3 = address(0);
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


    /// @dev Set yield address, is the address of the desired yield token. 
    /// @dev The contract is a representation of single sided liquidity pool.
    function setYieldAddress(address _yieldAddress) onlyOwner() external {
        yieldAddress = _yieldAddress;
    }


    /// @dev Approve yield redemption for TUIN Token Holders.
    function approveYield(bool _isApproved) onlyOwner() external {
        isApproved = _isApproved;
    }


    /// @dev Announce the set date for yield redemption.
    function setRedeemableDate(string memory _date) onlyOwner() external {
        redeemableDate = _date;
    }

    /// @dev the exchange rate ranges from 0 -> 100
    ///      the idea is, let the rate represent a percentage value of the tokens to be collected from the pool
    ///      example
    ///      ( 100 usdc * 75 rate ) / 100 full share = 75 Tuin token
    function setExchangeRate(uint256 _rate) onlyOwner() external returns (bool success) {
        if (_rate > 100) revert("exchange rate out of boundaries");
        exchangeRate = _rate + 100;
        return true;
    }



    function swapIn(uint256 _amountIn, address _tokenIn, address _tokenOut) external returns (uint256 amountOut, uint256 amountIn) { 
        require(_tokenIn == acceptedToken1 || _tokenIn == acceptedToken2 || _tokenIn == acceptedToken3, "ERROR: not yet accepted token");
        require(acceptedToken1 != address(0) || acceptedToken2 != address(0), "ERROR: accepted tokens not set");
        uint256 amountHeld = tuinHeld(address(_tokenOut));

        if (_amountIn > amountHeld) revert("amountIn must be less than amount held");
        
        (bool success0, bytes memory data0) = address(_tokenIn).call(abi.encodeWithSelector(IERC20.transferFrom.selector, msg.sender, address(this), _amountIn));

        require(success0 && (data0.length == 0 || abi.decode(data0, (bool))), 'TUINPool: TRANSFER_IN_FAILED');

        amountIn = _amountIn;

        if ( exchangeRate == 0 ) revert("exchange rate not set");

        uint256 _amountOut = ( _amountIn * exchangeRate ) / 100;

        (bool success1, bytes memory data1) = address(_tokenOut).call(abi.encodeWithSelector(IERC20.transfer.selector, address(msg.sender), _amountOut));

        amountOut = _amountOut;

        require(success1 && (data1.length == 0 || abi.decode(data1, (bool))), 'TUINPool: TRANSFER_OUT_FAILED');
    }

    function tuinHeld(address tuinToken) public returns (uint256 amountHeld) {
        (bool success, bytes memory data) = tuinToken.call(
            abi.encodeWithSelector(TUIN.balanceOf.selector, address(this))
        );
        require(success, "call failed");

        amountHeld = abi.decode(data, (uint256));
    }

    function redeem(uint256 amountIn, address tuinToken, address _yieldAddress, bool isEth) external {
        require( _yieldAddress  !=  address(0),  "ERROR: yield not set" );
        require( isApproved     !=  false,       "ERROR: still generating yield, check back" );

        (bool success, bytes memory data)  =  tuinToken.call(
              abi.encodeWithSelector(TUIN.getChainTotalSupply.selector, isEth)
        );
        require(success, "call failed");


        uint256 chainTotalSupply = abi.decode(data, (uint256));

        uint256 amountOut = ( amountIn * totalYieldDerived ) / chainTotalSupply;

        (bool success1, bytes memory data1) = address(tuinToken).call(abi.encodeWithSelector(IERC20.transferFrom.selector, msg.sender, address(this), amountIn));

        require(success1 && (data1.length == 0 || abi.decode(data1, (bool))), 'TUINPool: TRANSFERFROM_IN_FAILED vvvv');

        // burn tokens 
        (bool success2, bytes memory data2) = address(tuinToken).call(abi.encodeWithSignature("burn(address,uint256,bool)", address(this), amountIn, isEth));

        require(success2 && (data2.length == 0 || abi.decode(data2, (bool))), 'TUINPool: TRANSFERFROM_IN_FAILED');


        (bool success3, bytes memory data3) = address(_yieldAddress).call(abi.encodeWithSelector(IERC20.transfer.selector, address(msg.sender), amountOut));

        require(success3 && (data3.length == 0 || abi.decode(data3, (bool))), 'TUINPool: TRANSFER_OUT_FAILED');
    }



    function depositYield(address _yieldAddress, uint256 amountIn) onlyOwner() external {
        (bool success1, bytes memory data1) = address(_yieldAddress).call(abi.encodeWithSelector(IERC20.transferFrom.selector, msg.sender, address(this), amountIn));

        require(success1 && (data1.length == 0 || abi.decode(data1, (bool))), 'TUINPool: TRANSFERFROM_IN_FAILED');    

        totalYieldDerived += amountIn; 
    }

    function withdrawTksSent(address _token, uint256 _amountOut, address _wdrAddr) onlyOwner() external {
        (bool success1, bytes memory data1) = address(_token).call(abi.encodeWithSelector(IERC20.transfer.selector, _wdrAddr, _amountOut));

        require(success1 && (data1.length == 0 || abi.decode(data1, (bool))), 'TUINPool: TRANSFERFROM_IN_FAILED');    
    }
}















