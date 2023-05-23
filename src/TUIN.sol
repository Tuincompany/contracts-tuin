// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";








/**
 * @title ERC20 Token
 * @dev   Implementation Tuin v1.Tuin v1 is an ERC20 Token. All controls and changes have been reserved for Tuin wallet.
 *        Holders token balances are increased and decreased as guided by this contract.
 */

contract TUIN is IERC20 {
    address public           owner;
    address public immutable pool;
    string  public constant  name        = "Tuin v1";
    string  public constant  symbol      = "TT";
    uint8   public constant  decimals    = 18;
    uint256 public           totalSupply;



    /// @dev the specified token amount by surry for eth chain is 5 billion
    /// initial because tuin wallet is reserved the right to increase or decrease this supply
    uint256  public constant  init_maxsupply_on_eth = 5000000000 * 1e18;
    /// @dev the specified token amount by surry for bsc chain is 2 billion
    /// initial because tuin wallet is reserved the right to increase or decrease this supply
    uint256  public constant  init_maxsupply_on_bsc = 2000000000 * 1e18;


    uint256  public           maxsupply_on_eth      = init_maxsupply_on_eth;
    uint256  public           maxsupply_on_bsc      = init_maxsupply_on_bsc;


    uint256  public immutable deploymentChainId;



    /// @dev Records amount of Tuin token owned by an account.
    mapping ( address => uint256) internal _balances;

    /// @dev Records number of TUIN tokens that account (spender) will be allowed to spend on behalf of another account (owner).
    mapping ( address => mapping (address => uint256)) internal _allowed;





    /// @dev functions marked with onlyOwner can be called by only owner 
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    /// @dev functions marked with onlyPool can be called by only owner 
    modifier onlyPool {
        require(msg.sender == pool);
        _;
    }







    /**
     * @dev Constructor that gives poolContract initial max tokens. poolContract lists
     *      tokens on exchanges. 
     * @param _poolContract Address of poolcontract.
     */
    constructor(address _poolContract, bool isEth) {
        uint256 chainId;
        assembly {chainId := chainid()}
        deploymentChainId = chainId;
        owner = address(msg.sender);
        pool = _poolContract;


        if (isEth) {
            totalSupply = init_maxsupply_on_eth;
            _balances[_poolContract] = init_maxsupply_on_eth;
        } else {
            totalSupply = init_maxsupply_on_bsc;
            _balances[_poolContract] = init_maxsupply_on_bsc;
        }
    }       


    /**
     * @dev   function that sets the owner of the TUIN contract to _surryWallet
     *        initially the contract owner is set to the contracts deployer address  
     * @param _surryWallet Address of _surryWallet.
     */
    function setOwner(address _surryWallet) onlyOwner() external {
        owner = _surryWallet;
    }


    /**
     * @dev Creates new tokens and assigns them to an address in this case should be the pool contract.
     *      check on chain doesn't use chain id, this is so contract can be adaptable to more chains mintable 
     *      by admin
     * @param account The address to which the tokens will be minted.
     * @param amount The amount of tokens to be minted.
     * @return A boolean value indicating whether the operation succeeded.
     */
    function mint(address account, uint256 amount, bool isEth) onlyOwner() external returns(bool)  {
        require(account != address(0), 'TUIN ERC20: mint to zero address');
         
        // mint on ethereum chain
        if (isEth && totalSupply < maxsupply_on_eth) {
            _mint(account, amount);
        // else if mints on bnb
        } else if (!isEth && totalSupply < maxsupply_on_bsc) {
            _mint(account, amount);
        // specify the error
        } else {
            revert('ERROR: not right chain or attempt more than chain max supply');
        }
        
        emit Transfer(address(0), account, amount);

        return true;
    }


    function _mint(address account, uint256 amount) private {
        totalSupply += amount;
        _balances[account] += amount; 
    }


    /**
     * @dev    Burn tokens from the sender's account.
     *         check on chain doesn't use chain id, this is so contract can be adaptable to more chain burnable by pool redemption contract
     * @param  amount The amount of tokens to burn.
     * @param  isEth  The ethereum boolean identifier.
     * @return A boolean indicating whether the operation succeeded.
     */
    function burn(address account, uint256 amount, bool isEth) onlyPool() external returns (bool)  {
        require(account != address(0), 'TUIN ERC20: mint to zero address');
        require(amount <= _balances[account], 'burn amount exceeds balance');

        // burn on ethereum chain
        if (isEth && totalSupply <= maxsupply_on_eth) {
            _burn(account, amount);
        // else if burn on bsc
        } else if (!isEth && totalSupply <= maxsupply_on_bsc) {
            _burn(account, amount);
        // specify the error
        } else {
            revert('ERROR: not right chain or exceeds chain max supply');
        }
        

        emit Transfer(msg.sender, address(0), amount);

        return true;
    }


    function _burn(address account, uint256 amount) private {
        _balances[account] -= amount; 
        totalSupply -= amount;
    }


    /**
     * @dev Burn tokens from a specified account, subject to allowance.
     * @param _from The address whose tokens will be burned.
     * @param _amount The amount of tokens to burn.
     * @param isEth The ethereum boolean identifier.
     * @return A boolean indicating whether the operation succeeded.
     */
    function burnFrom(
        address _from,
        uint256 _amount,
        bool isEth
    ) external returns (bool) {
        require(_from != address(0), 'ERC20: from address is not valid');
        require(_balances[_from] >= _amount, 'ERC20: insufficient balance');
        require(_amount <= _allowed[_from][msg.sender], 'ERC20: burn from value not allowed');


        // burn on ethereum chain
        if (isEth && totalSupply <= maxsupply_on_eth) {
             _burnFrom(_from, _amount);
        // else if burn on bsc
        } else if (!isEth && totalSupply <= maxsupply_on_bsc) {
            _burnFrom(_from, _amount);
        // specify the error
        } else {
            revert('ERROR: not right chain or exceeds chain max supply');
        }

        emit Transfer(_from, address(0), _amount);

        return true;
    }


    function _burnFrom(address account, uint256 amount) private {
          _allowed[account][msg.sender] -= amount;
          _balances[account] -= amount;
          totalSupply -= amount;
    }


    /// @dev maxsupply_on_eth + maxsupplyon_bsc. this is the total amount of tokens that would ever be issued
    function maxSupply() external view returns (uint256) {
        return maxsupply_on_eth + maxsupply_on_bsc;
    }
    

    /// @dev Tuins supply on eth should only be changeable by the Tuins wallet.
    ///      restrict access using a modifier
    function changeSupplyOnEth(uint256 _new_maxsupply_on_eth) onlyOwner() external {
        require(totalSupply < _new_maxsupply_on_eth, "ERROR: value lesser than or equal to total supply");
        maxsupply_on_eth = _new_maxsupply_on_eth;
    }


    /// @dev Tuins supply on bsc should only be changeable by the Tuins wallet.
    ///      restrict access using a modifier
    function changeSupplyOnBsc(uint256 _new_maxsupply_on_bsc) onlyOwner() external {
        require(totalSupply < _new_maxsupply_on_bsc, "ERROR: value lesser than or equal to total supply");
        maxsupply_on_bsc = _new_maxsupply_on_bsc;
    }


    /**
    * @dev    Gets the balance of the specified address.
    * @param  _owner The address to query the balance of.
    * @return balance An uint256 representing the balance
    */
    function balanceOf(
       address _owner
     ) external view returns (uint256 balance) {
        return _balances[_owner];
    }


    /**
     * @dev     After a user purchases TUIN, a user must be able to transfer tuin token for a specified address.
     *          Tuin are redeemable 1:1 for profit
     * @param   _to The address to transfer to.
     * @param   _value The amount to be transferred.
     * @return  A boolean that indicates if the operation was successful.
     */
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


     /**
     * @dev    Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * @param  _spender The address which will spend the funds.
     * @param  _value The amount of tokens to be spent.
     * @return A boolean that indicates if the operation was successful.
     */
    function approve(
       address _spender, 
       uint256 _value
    ) external returns (bool) {
        _allowed[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        
        return true;
   }


    /**
    * @dev    Transfer tokens from one address to another.
    * @param  _from The address which you want to send tokens from.
    * @param  _to The address which you want to transfer to.
    * @param  _value The amount of tokens to be transferred.
    * @return A boolean that indicates if the operation was successful
    */
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


    /**
     * @dev Returns the amount of tokens approved by the owner that can be transferred to the spender's account.
     * @param _owner The address of the owner of the tokens.
     * @param _spender The address of the spender.
     * @return The number of tokens approved.
     */
    function allowance(
        address _owner, 
        address _spender
    ) external override view returns (uint256) {
        return _allowed[_owner][_spender];
    }


    /**
     * @dev    Increases the amount of tokens that an owner has allowed to a spender.
     * @param  _spender The address of the spender.
     * @param  _addedValue The amount of tokens to increase the allowance by.
     * @return A boolean value indicating whether the operation succeeded.
     */
    function increaseApproval(
        address _spender, 
        uint256 _addedValue
    ) external returns (bool) {
        _allowed[msg.sender][_spender] += _addedValue;

        emit Approval(msg.sender, _spender, _allowed[msg.sender][_spender]);
        
        return true;
    }


    /**
     * @dev Decreases the amount of tokens that an owner has allowed to a spender.
     * @param _spender The address of the spender.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     * @return A boolean value indicating whether the operation succeeded.
     */
    function decreaseApproval(
        address _spender, 
        uint256 _subtractedValue
    ) external returns (bool) {
        uint256 oldValue = _allowed[msg.sender][_spender];
        
        if (_subtractedValue > oldValue) {
            _allowed[msg.sender][_spender] = 0;
        } else {
            _allowed[msg.sender][_spender] = oldValue - _subtractedValue;
        }
        
        emit Approval(msg.sender, _spender, _allowed[msg.sender][_spender]);
        
        return true;
    }


    //    change to ethchainId
    function getChainTotalSupply(bool isEth) external view returns(uint256) {
       if (isEth) return maxsupply_on_eth;
       return maxsupply_on_bsc;
    }
}
