// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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
  
contract SURRYWallet {
    address public owner;

    /// @dev functions marked with onlyOwner can be called by onlyOwner. 
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    /// @dev constructor that sets the owner to msg.sender.
    constructor () {
        owner = address(msg.sender);
    }

    /// @dev sets a new wallet owner to the specified address _newOwner.
    function setOwner(address _newOwner) onlyOwner() external {
        owner = _newOwner;
    }

    /// @dev wallet first has to be delegated ownership by contracts deployer.
    function setTuinOwner(address tuinToken, address _newOwner) onlyOwner() external returns (bool success) {
        (success,) = tuinToken.call(
            abi.encodeWithSignature("setOwner(address)", _newOwner)
        );

        require(success, "failed to change owner");
    }

    /// @dev sets a new max supply value, which means total mintable balance on the network has increased
    function setNewSupply(address tuinToken, uint256 _newMaxSupply, bool isEth) onlyOwner() external returns (bool success) {
        string memory _signatureOnEth = "changeSupplyOnEth(uint256)";
        string memory _signatureOnBsc = "changeSupplyOnBsc(uint256)";
        if (isEth) {
            (success,) = tuinToken.call(
                abi.encodeWithSignature(_signatureOnEth, _newMaxSupply)
                );
        } else {
            (success,) = tuinToken.call(
                abi.encodeWithSignature(_signatureOnBsc, _newMaxSupply)
                );
        }
        
        require(success, "failed to set new supply");
    }

    function newMint(address tuinToken, address _to, uint256 _amount, bool isEth) onlyOwner() external returns (bool success) {
        (success,) = tuinToken.call(
                abi.encodeWithSignature("mint(address,uint256,bool)", _to, _amount, isEth)
            );

        require(success, "failed to new mint");
    }

    /// @dev wallet first has to be delegated ownership by contracts deployer.
    function setTUINPoolOwner(address tuinPool, address _newOwner) onlyOwner() external returns (bool success) {
        (success,) = tuinPool.call(
            abi.encodeWithSignature("setOwner(address)", _newOwner)
        );

        require(success, "failed to change pool owner");
    }

    /// @dev wallet first has to be delegated ownership by contracts deployer.
    function setAcceptedToken(address tuinPool, address _token, uint8 _funcNo) onlyOwner() external returns (bool success) {
        if (_funcNo < 1 || _funcNo > 3) revert("ERROR: Accepted token is either 1,2,3");
        string memory acceptedTk1Sgn = "setAcceptedToken1(address)";
        string memory acceptedTk2Sgn = "setAcceptedToken2(address)";
        string memory acceptedTk3Sgn = "setAcceptedToken3(address)";

        if ( _funcNo == 1 ) {
            (success,) = tuinPool.call(
                abi.encodeWithSignature(acceptedTk1Sgn, _token)
            );
        } else if ( _funcNo == 2 ) {
            (success,) = tuinPool.call(
                abi.encodeWithSignature(acceptedTk2Sgn, _token)
            );
        } else if ( _funcNo == 3 ) {
            (success,) = tuinPool.call(
                abi.encodeWithSignature(acceptedTk3Sgn, _token)
            );
        } 


        require(success, "failed to set accepted token");
    }

    /// @dev setYieldAddress set the redeemable token
    function setYieldAddress(address tuinPool, address _token) onlyOwner() external returns (bool success) {
            (success,) = tuinPool.call(
                abi.encodeWithSignature("setYieldAddress(address)", _token)
            );

            require(success, "failed to set yield address");
    }

    function setApproveYield(address tuinPool, bool _approved) onlyOwner() external returns (bool success) {
            (success,) = tuinPool.call(
                abi.encodeWithSignature("approveYield(bool)", _approved)
            );

            require(success, "failed to set whether yield approved");
    }

    function setRedeemableDate(address tuinPool, string memory _date) onlyOwner() external returns (bool success) {
            (success,) = tuinPool.call(
                abi.encodeWithSignature("setRedeemableDate(string)", _date)
            );

            require(success, "failed to set redeemable date");
    }

    function setExchangeRate(address tuinPool, uint256 _newRate) onlyOwner() external returns (bool success) {
            (success,) = tuinPool.call(
                abi.encodeWithSignature("setExchangeRate(uint256)", _newRate)
            );

            require(success, "failed to set whether exchange rate");
    }

    function putDepositYield(address tuinPool, address _yieldAddress, uint256 amountIn) external returns (bool success) {
            (bool success1, bytes memory data1) = address(_yieldAddress).call(abi.encodeWithSelector(IERC20.transferFrom.selector, msg.sender, address(this), amountIn));

            require(success1 && (data1.length == 0 || abi.decode(data1, (bool))), 'Yield: TRANSFERFROM_IN_FAILED'); 

            (bool success2, bytes memory data2) = address(_yieldAddress).call(abi.encodeWithSelector(IERC20.approve.selector, address(tuinPool), amountIn));

            require(success2 && (data2.length == 0 || abi.decode(data2, (bool))), 'Yield: TRANSFERFROM_IN_FAILED'); 

            
            (success,) = tuinPool.call(
                abi.encodeWithSignature("depositYield(address,uint256)", _yieldAddress, amountIn)
            );

            require(success, "failed to put yield into pool");
    }
}