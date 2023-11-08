// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";


contract ERC20 is Context, IERC20, IERC20Metadata {
    
    struct Data {
        uint tokenBalance;
        uint shareBalance;
        uint fractionalShareBalance;
        uint registrationHash;
        bool recoverable;
    }
    
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => Data) public registry;
    uint256 private _totalSupply;
    bool public paused;
    string private _name;
    string private _symbol;
    address public corporation;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Registered(address indexed account, uint256 registrationHash);
    event AskedForRecovery(address indexed account);
    event Recovered(address indexed account);
    
    
    modifier whenUnpaused() {
        require(paused, "ERC20: token is not paused"); _;}

    modifier onlyOwner() {
        require(msg.sender == corporation, "ERC20: only corporation can call this function"); _;}

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        corporation = msg.sender;
        paused = false;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function pause() public onlyOwner whenUnpaused {
        require(msg.sender == corporation, "ERC20: only corporation can pause");
        paused = true;
    }

    function unpause() public onlyOwner {
        require(msg.sender == corporation, "ERC20: only corporation can unpause");
        paused = false;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return registry[account].tokenBalance;
    }

    function shareBalanceOf(address account) public view virtual override returns (uint256) {
        return registry[account].shareBalance;
    }

    function fractionalShareBalanceOf(address account) public view virtual override returns (uint256) {
        return registry[account].fractionalShareBalance;
    }

    function transfer(address to, uint256 amount) public virtual override whenUnpaused returns (bool) {
        require (amount <= registry[msg.sender].tokenBalance, "Token balance is not enough");
        shares = amount / 1e18;
        fractions = amount % 1e18;

        if (fractions > registry[msg.sender].fractionalShareBalance) {
            registry[msg.sender].shareBalance -= 1;
            registry[corporation].shareBalance += 1;
            registry[msg.sender].fractionalShareBalance += 1e18;
            registry[corporation].fractionalShareBalance -= 1e18;
        }
        registry[msg.sender].shareBalance -= shares;
        registry[msg.sender].fractionalShareBalance -= fractions;
        registry[msg.sender].tokenBalance -= amount;

        if (fractions < registry[to].fractionalShareBalance) {
            registry[to].shareBalance += 1;
            registry[corporation].shareBalance -= 1;
            registry[to].fractionalShareBalance -= 1e18;
            registry[corporation].fractionalShareBalance += 1e18;
        }
        registry[to].shareBalance += shares;
        registry[to].fractionalShareBalance += fractions;
        registry[to].tokenBalance += amount;

        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override whenUnpaused returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual onlyOwner whenUnpaused {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        registry[corporation].shareBalance += amount / 1e18;
        registry[corporation].tokenBalance += amount;
        registry[corporation].fractionalShareBalance += amount % 1e18;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual  onlyOwner whenUnpaused {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function registerHash(bytes32 hash) public {
        require(registry[msg.sender].registrationHash != 0, "Address already registered");
        registry[msg.sender].registrationHash = hash;
        emit Registered(msg.sender, hash);
    }

    function askForRecovery(address account) public payable {
        require(account != address(0), "ERC20: approveRecovery to the zero address");
        require(registry[account].registrationHash != 0, "ERC20: account must be registered");
        require(msg.value >= 1e18, "You must pay at least 1 MATIC");
        registry[account].recoverable = true;
        emit AskedForRecovery(account);
    }

    function recover(address lostAddress, address newAddress) public onlyOwner whenUnpaused {
        require(lostAddress != address(0), "Invalid lost address");
        require(newAddress != address(0), "Invalid new address");
        require(lostAddress != newAddress, "Lost address cannot be the same as new address");
        require(registry[lostAddress].registrationHash != 0, "Lost address must be registered");
        require(registry[newAddress].tokenBalance == 0, "New address must be registered");
        require(registry[lostAddress].recoverable, "Lost address must be recoverable");

        registry[newAddress] = registry[lostAddress];
        registry[newAddress].recoverable = false;
        registry[newAddress] = 0;

        emit Recovery(lostAddress, newAddress, _balances[newAddress]);
    }
}