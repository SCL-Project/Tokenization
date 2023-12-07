// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC20 {
    struct InvestorData {
        uint256 tokenBalance;
        uint256 shareBalance;
        uint256 fractionalPartOfTokenBalance; // Updated
        bytes32 registrationHash;
        bool recoverable;
    }
    mapping(address => InvestorData) private registry;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply; // is private since ERC20 has a public function totalSupply()
    uint256 private constant ONE_TOKEN = 1e18; // 1 Share corresponds to 1e18
    uint256 public recoveryPrice = 1e18; // default: recovery costs 1 Ether/Matic
    bool public paused;
    string private _name; // underlines help to distinguish variables from functions that are named the same
    string private _symbol;
    address public owner;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Registered(address indexed account, bytes32 registrationHash);
    event AskedForRecovery(address indexed account);
    event Recovered(address indexed account);

    modifier whenUnpaused() {
        require(paused == false, "ERC20: token is not paused");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "ERC20: only corporation can call this function");
        _;
    }

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        owner = msg.sender;
        paused = false;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function pause() public onlyOwner whenUnpaused {
        paused = true;
    }

    function unpause() public onlyOwner {
        paused = false;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return registry[account].tokenBalance;
    }

    function shareBalanceOf(address account) public view returns (uint256) {
        return registry[account].shareBalance;
    }

    function fractionalPartOfTokenBalanceOf(address account) public view virtual returns (uint256) {
        return registry[account].fractionalPartOfTokenBalance; // Updated
    }

    function transfer(address to, uint256 amount) public whenUnpaused returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address _owner, address spender) public view returns (uint256) {
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        address _owner = msg.sender;
        _approve(_owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public whenUnpaused returns (bool) {
        address spender = msg.sender;
        uint256 currentAllowance = allowance(from, spender);
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        address _owner = msg.sender;
        _approve(_owner, spender, allowance(_owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        address _owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero.");
        unchecked {
            _approve(_owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function mint(address to, uint256 amount) public onlyOwner whenUnpaused {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyOwner whenUnpaused {
        _burn(from, amount);
    }

    function _mint(address to, uint256 amount) internal virtual onlyOwner whenUnpaused {
        uint256 shares = amount / ONE_TOKEN;
        uint256 fractions = amount % ONE_TOKEN;

        if (fractions < registry[to].fractionalPartOfTokenBalance) {
            registry[to].shareBalance += 1;
            registry[owner].shareBalance -= 1;
            registry[to].fractionalPartOfTokenBalance -= ONE_TOKEN;
            registry[owner].fractionalPartOfTokenBalance += ONE_TOKEN;
    }
        registry[to].shareBalance += shares;
        registry[to].fractionalPartOfTokenBalance += fractions;
        registry[to].tokenBalance += amount;
        _totalSupply += amount;

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual onlyOwner whenUnpaused {
        require(registry[from].tokenBalance >= amount, "Burn amount exceeds balance.");
        uint256 shares = amount / ONE_TOKEN;
        uint256 fractions = amount % ONE_TOKEN;

        if (fractions > registry[from].fractionalPartOfTokenBalance) {
            registry[from].shareBalance -= 1;
            registry[owner].shareBalance += 1;
            registry[from].fractionalPartOfTokenBalance += ONE_TOKEN;
            registry[owner].fractionalPartOfTokenBalance -= ONE_TOKEN;
        }
        registry[from].shareBalance -= shares;
        registry[from].fractionalPartOfTokenBalance -= fractions;
        registry[from].tokenBalance -= amount;
        _totalSupply -= amount;

        emit Transfer(from, address(0), amount);
    }

    function _approve(address _owner, address spender, uint256 amount) internal virtual { // This function helps to shorten approve and increaseAllowance
        require(_owner != address(0), "ERC20: approve from the zero address.");
        require(spender != address(0), "ERC20: approve to the zero address.");

        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal virtual { // This function helps to shorten transfer and transferFrom
        require(amount <= registry[from].tokenBalance, "Transfer amount exceeds balance.");

        uint256 shares = amount / ONE_TOKEN;
        uint256 fractions = amount % ONE_TOKEN;

        if (fractions > registry[from].fractionalPartOfTokenBalance) {
            registry[from].shareBalance -= 1;
            registry[owner].shareBalance += 1;
            registry[from].fractionalPartOfTokenBalance += ONE_TOKEN;
            registry[owner].fractionalPartOfTokenBalance -= ONE_TOKEN;
        }
        registry[from].shareBalance -= shares;
        registry[from].fractionalPartOfTokenBalance -= fractions;
        registry[from].tokenBalance -= amount;

        if (fractions < registry[to].fractionalPartOfTokenBalance) {
            registry[to].shareBalance += 1;
            registry[owner].shareBalance -= 1;
            registry[to].fractionalPartOfTokenBalance -= ONE_TOKEN;
            registry[owner].fractionalPartOfTokenBalance += ONE_TOKEN;
    }
        registry[to].shareBalance += shares;
        registry[to].fractionalPartOfTokenBalance += fractions;
        registry[to].tokenBalance += amount;

        emit Transfer(from, to, amount);
    }

    function registerHash(bytes32 hash) public {
        registry[msg.sender].registrationHash = hash;
        emit Registered(msg.sender, hash);
    }

    function askForRecovery(address account) public payable {
        require(msg.value >= recoveryPrice, "Not enough ether sent."); // investor should be charged in case of recovery
        require(registry[account].registrationHash != 0, "Account must be registered.");
        registry[account].recoverable = true;
        emit AskedForRecovery(account);
    }

    function setRecoveryPrice(uint256 price) public onlyOwner {
        recoveryPrice = price;
    }

    function recover(address oldAddress, address newAddress) public onlyOwner whenUnpaused {
        require(oldAddress != newAddress, "Old address cannot be the same as new address.");
        require(registry[newAddress].tokenBalance == 0, "New address must not be in use.");
        require(registry[oldAddress].recoverable, "Old address not marked for recovery. Please ask for recovery first.");

        registry[newAddress] = registry[oldAddress];
        delete registry[oldAddress];
        emit Recovered(oldAddress);
    }
}
