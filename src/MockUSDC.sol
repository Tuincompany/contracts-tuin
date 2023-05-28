// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { IERC20 } from "./interface/IERC20.sol";

contract MockUSDC is IERC20 {
    string public constant name = "US DOLLAR COIN";
    string public constant symbol = "USDC";
    uint8  public constant decimals = 6;
    uint256 public totalSupply;

    /// @dev Records amount of Tuin token owned by an account.
    mapping ( address => uint256) private _balances;

    /// @dev Records number of TUIN tokens that account (spender) will be allowed to spend on behalf of another account (owner).
    mapping ( address => mapping (address => uint256)) private _allowed;

    constructor()  {
        _mint(msg.sender, 5000000000e6);
    }

    function _mint(address account, uint256 amount) public {
        totalSupply += amount;
        _balances[account] += amount;
    }

    function balanceOf(address _owner) external view returns (uint256 balance) {
        return _balances[_owner];
    }

    function transfer(
        address _to, 
        uint256 _value
    ) external returns (bool) {
        require(_to != address(0), 'ERC20: to address is not valid');
        require(_value <= _balances[msg.sender], 'ERC20: insufficient balance');

        _balances[msg.sender] -= _value;
        _balances[_to] += _value;
        
        emit Transfer(msg.sender, _to, _value);
        
        return true;
    }

     function allowance(
        address _owner, 
        address _spender
    ) external override view returns (uint256) {
        return _allowed[_owner][_spender];
    }

    function approve(
       address _spender, 
       uint256 _value
    ) external returns (bool) {
        _allowed[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        
        return true;
   }

   function transferFrom(
        address _from, 
        address _to, 
        uint256 _value
    ) external returns (bool) {
        require(_from != address(0), 'ERC20: from address is not valid');
        require(_to != address(0), 'ERC20: to address is not valid');
        require(_value <= _balances[_from], 'ERC20: insufficient balance');
        require(_value <= _allowed[_from][msg.sender], 'ERC20: transfer from value not allowed');

        _allowed[_from][msg.sender] -= _value;
        _balances[_from] -= _value;
        _balances[_to] += _value;
        
        emit Transfer(_from, _to, _value);
        
        return true;
   }
}
