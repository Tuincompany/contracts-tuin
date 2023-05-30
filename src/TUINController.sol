// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interface/IERC20.sol";

/**     
 * @title SURRYWallet
 * @dev   Implementation of surry control, permission, and configuration wallet. 
 *
 *        Boundaries controlled by wallet on Tuin, are as follows:
 *        setOwner which sets ownership
 *        mint     which mints new amount of tokens
 *        changeSupplyOnEth which increases the current supply of mintable tuin token on ETH
 *        changeSupplyOnBsc which increases the current supply of mintable tuin token on BSC 
 *
 *        Boundaries controlled by wallet on TUINPool, are as follows:
 *        setOwner(address): sets owner address of the pool
 *        setAcceptedToken1(address): sets accepted user deposit token e.g usdc, busd 
 *        setAcceptedToken2(address): sets accepted 2nd user deposit token e.g usdc / busd
 *        setAcceptedToken3(address): sets accepted 3 user deposits
 *        setYieldAddress(address):   sets yieldAddress(address) the address of the yield deposit token.
 *        approveYield(bool): alloows yield for redemption 
 *        setRedeemableDate(string): announces the day for yield redemption
 *        setExchangeRate(_rate): set the allowed buy rate 
 */
  
contract TUINController {
    /// @dev owner of this contract
    ///      should be an EOA
    address public owner;

    /// @dev functions marked with onlyOwner can be called by onlyOwner. 
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    /// deployer passes ownership 
    /// @dev constructor that sets the owner to msg.sender.
    constructor () {
        owner = address(msg.sender);
    }

    /// @dev sets a new wallet owner to the specified address _newOwner.
    function setOwner(address _newOwner) onlyOwner() external {
        require(address(this) != _newOwner, "cant own itself");

        owner = _newOwner;
    }
      
    /// @dev wallet first has to be delegated ownership by contracts deployer.
    function setTuinOwner(address tuinToken, address _newOwner) onlyOwner() external  {
        (bool success, bytes memory data) = tuinToken.call(
            abi.encodeWithSignature("setOwner(address)", _newOwner)
        );

        require( success  &&  data.length  >=  32, "Err: failed to change owner" );
    }

    /// @dev wallet first has to be delegated ownership by contracts deployer.
    function setTuinPoolAddress(address tuinToken, address _newPool) onlyOwner() external  {
        (bool success, bytes memory data) = tuinToken.call(
            abi.encodeWithSignature("setPool(address)", _newPool)
        );

        require( success  &&  data.length  >=  32, "Err: failed to set new pool" );
    }
    
    /// @dev sets a new max supply value, which means total mintable balance on the network has increased
    function setNewSupply(address tuinToken, uint256 _newMaxSupply) onlyOwner() external returns (bool) {
        uint8 deploymentChainId;

        assembly { deploymentChainId := chainid() }

        bool isEth = deploymentChainId == 1;
        bool success;
        bytes memory data;
        string memory _signatureOnEth = "changeSupplyOnEth(uint256)";
        string memory _signatureOnBsc = "changeSupplyOnBsc(uint256)";
       
        if (isEth) {


            (success, data) = tuinToken.call(
                abi.encodeWithSignature(_signatureOnEth, _newMaxSupply)
                );

            require( success  &&  data.length  >=  32, "Err: failed to set new supply on eth" );

            return success;
        }


        (success, data) = tuinToken.call(
            abi.encodeWithSignature(_signatureOnBsc, _newMaxSupply)
        );    

        
        require( success  &&  data.length  >=  32, "Err: failed to set new supply on bsc" );


        return success;  
    }

    function newMint(address tuinToken, address _to, uint256 _amount) onlyOwner() external returns (bool) {
        (bool success, bytes memory data) = tuinToken.call(
                abi.encodeWithSignature("mint(address,uint256)", _to, _amount)
            );
        
        require( success  &&  data.length  >=  32, "failed to new mint" );

        return success;
    }

    /// @dev wallet first has to be delegated ownership by contracts deployer.
    function setTUINPoolOwner(address tuinPool, address _newOwner) onlyOwner() external returns (bool) {
        (bool success, bytes memory data) = tuinPool.call(
            abi.encodeWithSignature("setOwner(address)", _newOwner)
        );

        require( success  &&  data.length  >=  32, "failed to change pool owner" );

        return success;
    }

    /// @dev wallet first has to be delegated ownership by contracts deployer.
    function setPaused(address tuinPool, bool _paused) onlyOwner() external returns (bool) {
        (bool success, bytes memory data) = tuinPool.call(
            abi.encodeWithSignature("setPaused(bool)", _paused)
        );

        require( success  &&  data.length  >=  32, "failed to pause pool" );

        return success;
    }

    /// @dev wallet first has to be delegated ownership by contracts deployer.
    function setAcceptedToken(address tuinPool, address _token, uint8 _funcNo) onlyOwner() external returns (bool) {
        if (_funcNo < 1 || _funcNo > 3) revert("ERROR: Accepted token is either 1,2,3");


        string memory acceptedTk1Sgn = "setAcceptedToken1(address)";
        string memory acceptedTk2Sgn = "setAcceptedToken2(address)";
        string memory acceptedTk3Sgn = "setAcceptedToken3(address)";


        bool success;
        bytes memory data;


        if ( _funcNo == 1 ) {

            (success, data) = tuinPool.call(
                abi.encodeWithSignature(acceptedTk1Sgn, _token)
            );
        } else if ( _funcNo == 2 ) {

            (success, data) = tuinPool.call(
                abi.encodeWithSignature(acceptedTk2Sgn, _token)
            );
        } else if ( _funcNo == 3 ) {

            (success, data) = tuinPool.call(
                abi.encodeWithSignature(acceptedTk3Sgn, _token)
            );
        } 


        require( success  &&  data.length  >=  32, "failed to set accepted token" );

        return true;
    }

    /// @dev setYieldAddress set the redeemable token
    function setYieldToken(address tuinPool, address _token) onlyOwner() external returns (bool) {
            (bool success, bytes memory data) = tuinPool.call(
                abi.encodeWithSignature("setYieldToken(address)", _token)
            );

            require( success  &&  data.length  >=  32, "failed to set yield address" );

            return true;
    }

    function setApproveYield(address tuinPool, bool _approved) onlyOwner() external returns (bool) {
            (bool success, bytes memory data) = tuinPool.call(
                abi.encodeWithSignature("approveYield(bool)", _approved)
            );


            require( success  &&  data.length  >=  32, "failed to set whether yield approved" );

            return true;
    }

    function setRedeemableDate(address tuinPool, string memory _date) onlyOwner() external returns (bool) {
            (bool success, bytes memory data) = tuinPool.call(
                abi.encodeWithSignature("setRedeemableDate(string)", _date)
            );

          
            require( success  &&  data.length  >=  32, "failed to set redeemable date" );

            return true;
    }
    // 1 usd = x tuin tokens
    // used in swap function
    function setExchangeRateTuin(address tuinPool, uint256 _newRate) onlyOwner() external returns (bool) {
            (bool success, bytes memory data) = tuinPool.call(
                abi.encodeWithSignature("setExchangeRateTuin(uint256)", _newRate)
            );

            require( success  &&  data.length  >=  32, "failed to set whether exchange rate TUIN" );

            return true;
    }

    // 1 = x usd tokens
    // used in the redeem function
    function setExchangeRateUsd(address tuinPool, uint256 _newRate) onlyOwner() external returns (bool) {
            (bool success, bytes memory data) = tuinPool.call(
                abi.encodeWithSignature("setExchangeRateUsd(uint256)", _newRate)
            );

            require( success  &&  data.length  >=  32, "failed to set whether exchange rate TUIN" );

            return true;
    }

    // we deposit into the contract and approve the spender is the pool contract
    function putDepositYield(address tuinPool, address _yieldAddress, uint256 amountIn) external returns (bool) {

            (bool success1, bytes memory data1) = address(_yieldAddress).call(abi.encodeWithSelector(IERC20.transferFrom.selector, msg.sender, address(this), amountIn));

            require( success1  &&  data1.length  >=  32, 'Yield: TRANSFERFROM_IN_FAILED' );

            (bool success2, bytes memory data2) = address(_yieldAddress).call(abi.encodeWithSelector(IERC20.approve.selector, address(tuinPool), amountIn));

            require( success2  &&  data2.length  >=  32, 'Yield: TRANSFERFROM_IN_FAILED' );

            
            (bool success, bytes memory data) = tuinPool.call(
                abi.encodeWithSignature("depositYieldToken(address,uint256)", _yieldAddress, amountIn)
            );

            require( success  &&  data.length  >=  32, "Err: Failed To Deposit Yield" );

            return true;
    }

    function withdraw(address tuinPool, address _tokenIn, address _to, uint256 _amountOut) onlyOwner() external returns (bool) {
        (bool success, bytes memory data) = tuinPool.call(
                abi.encodeWithSignature("withdrawAcceptedToken(address,address,uint256)", _tokenIn, _to, _amountOut)
            );

            require( success  &&  data.length  >=  32, "Err: Failed To Withdraw" );

            return true;
    }
}