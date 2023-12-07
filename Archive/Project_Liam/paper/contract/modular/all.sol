// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}


contract Ownable {

    mapping(address => bool) private ownersMap;
    address[] private ownersList;

    modifier onlyOwners {
        require(ownersMap[msg.sender], "Ownable: You are not an owner");
        _;
    }

    constructor() {
        ownersMap[msg.sender] = true;
        ownersList.push(msg.sender);
    }

    function addOwner(address _newOwner) public onlyOwners returns (bool) {
        ownersMap[_newOwner] = true;
        ownersList.push(_newOwner);
        return true;
    }

    function removeOwner(address _oldOwner) public onlyOwners returns (bool) {
        ownersMap[_oldOwner] = false;
        for (uint i = 0; i < ownersList.length; i++) {
            if (ownersList[i] == _oldOwner) {
                ownersList[i] = ownersList[ownersList.length - 1];
                ownersList.pop();
                break;
            }
        }
        return true;
    }

    function owners() public view returns (address[] memory) {
        return ownersList;
    }
}


contract Pausable {

    bool private paused;

    event Paused(uint256 time);
    event Unpaused(uint256 time);

    constructor() {
        paused = false;
    }

    modifier whenNotPaused() {
        require(paused == false, "Pausable: Contract is not paused");
        _;
    }

    modifier whenPaused() {
        require(paused == true, "Pausable: Contract is paused");
        _;
    }

    function isPaused() public view returns (bool) {
        return paused;
    }

    function pause() public virtual {
        paused = true;
        emit Paused(block.timestamp);
    }

    function unpause() public virtual {
        paused = false;
        emit Unpaused(block.timestamp);
    }
}


contract ERC20 is IERC20, Ownable, Pausable {

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view override returns (string memory) {return _name;}

    function symbol() public view override returns (string memory) {return _symbol;}

    function decimals() public view override returns (uint8) {return _decimals;}

    function totalSupply() public view override returns (uint256) {return _totalSupply;}

    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}

    function transfer(address to, uint256 amount) public whenNotPaused override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public whenNotPaused override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _update(from, to, amount);
    }

    function _update(address from, address to, uint256 amount) internal virtual {
        if (from == address(0)) {
            _totalSupply += amount;
        } else {
            uint256 fromBalance = _balances[from];
            require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
            unchecked {
                // Overflow not possible: amount <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - amount;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: amount <= totalSupply or amount <= fromBalance <= totalSupply.
                _totalSupply -= amount;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + amount is at most totalSupply, which we know fits into a uint256.
                _balances[to] += amount;
            }
        }
        emit Transfer(from, to, amount);
    }

    function mint(address account, uint256 amount) public whenNotPaused onlyOwners returns (bool) {
        _mint(account, amount);
        return true;
    }

    function burn(uint256 amount) public whenNotPaused onlyOwners returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _update(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        _update(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function pause() public whenNotPaused onlyOwners override {super.pause();}

    function unpause() public whenPaused onlyOwners override {super.unpause();}
}


abstract contract Registry is ERC20 {

    struct InvestorData {
        uint256 shareBalance;
        uint256 fractionalPartOfTokenBalance;
        bytes32 registrationHash;
        bool recoverable;
        uint timeOfFirstUse;
    }

    mapping(address => InvestorData) public registry;
        uint256 private fractionedShares;
    uint256 private ONE_TOKEN;

    constructor() {ONE_TOKEN = 10 ** decimals();}

    function shareBalanceOf(address account) public view returns (uint256) {
        return registry[account].shareBalance;
    }

    function fractionalPartOfTokenBalanceOf(address account) public view returns (uint256) {
        return registry[account].fractionalPartOfTokenBalance;
    }

    function totalFractionedSupply() public view returns (uint256) {
        return fractionedShares;
    }

    function totalFullSupply() public view returns (uint256) {
        return totalSupply() - fractionedShares;
    }

    function calculateShares(address account) internal {
        uint256 tokens = balanceOf(account);
        uint256 shares = tokens / ONE_TOKEN;
        uint256 fractions = tokens % ONE_TOKEN;

        registry[account].shareBalance = shares;
        registry[account].fractionalPartOfTokenBalance = fractions;
    }

    function _update(address from, address to, uint256 amount) internal virtual override {
        super._update(from, to, amount);

        uint256 fractionsFromBefore = registry[from].fractionalPartOfTokenBalance;
        uint256 fractionsToBefore = registry[to].fractionalPartOfTokenBalance;

        if (from != address(0)) {
            calculateShares(from);
            if (registry[from].timeOfFirstUse == 0) {
                registry[from].timeOfFirstUse = block.timestamp;
            }
        }

        if (to != address(0)) {
            calculateShares(to);
            if (registry[to].timeOfFirstUse == 0) {
                registry[to].timeOfFirstUse = block.timestamp;
            }
        }

        uint256 fractionsFromAfter = registry[from].fractionalPartOfTokenBalance;
        uint256 fractionsToAfter = registry[to].fractionalPartOfTokenBalance;

        fractionedShares += (fractionsFromAfter - fractionsFromBefore) + (fractionsToAfter - fractionsToBefore);
    }
}


abstract contract Offering is Registry {

    uint256 public offeringPrice;
    uint256 public offeringAmount;
    bool public offering;

    function startOffering(uint _price, uint _amount) public onlyOwners returns (bool) {
        offeringPrice = _price;
        offeringAmount = _amount;
        offering = true;
        return true;
    }

    function changePrice(uint _price) public onlyOwners returns (bool) {
        offeringPrice = _price;
        return true;
    }

    function changeAmount(uint _amount) public onlyOwners returns (bool) {
        offeringAmount = _amount;
        return true;
    }

    function stopOffering() public returns (bool) {
        offeringPrice = 0;
        offering = false;
        return true;
    }

    function buyTokens() public payable returns (uint) {
        require(offering, "Offering: No Tokens are being offered at the moment");
        uint256 _buyAmount = 10**decimals() * msg.value / offeringPrice;

        if (_buyAmount >= offeringAmount) {
            uint256 repayment = (msg.value - (offeringAmount * offeringPrice));
            payable(msg.sender).transfer(repayment);
            _buyAmount = offeringAmount;
            stopOffering();
        }

        _mint(msg.sender, _buyAmount);
        offeringAmount -= _buyAmount;
        return _buyAmount;
    }

    function withdraw() public onlyOwners returns (bool) {
        payable(msg.sender).transfer(address(this).balance);
        return true;
    }
}


abstract contract Announcement is Registry {

    event _Announcement(uint date, string announcement);

    function announcement(string memory _announcement) public onlyOwners returns(bool) {
        emit _Announcement(block.timestamp, _announcement);
        return true;
        }
}


abstract contract Registration is Registry {

    event Registered(address indexed account, bytes32 registrationHash);

    function registerHash(bytes32 hash) public {
        registry[msg.sender].registrationHash = hash;
        emit Registered(msg.sender, hash);
    }

    function getHash(address account) internal view returns (bytes32) {
        return registry[account].registrationHash;
    }
}


abstract contract Recovery is Registration {

    uint256 public recoveryPrice;
    event AskedForRecovery(address indexed account);
    event Recovered(address indexed account);


    constructor() {
        recoveryPrice = 1e18; // default: recovery costs 1 Ether/Matic
    }

    function askForRecovery(address account) public payable {
        require(msg.value >= recoveryPrice, "Not enough ether sent."); // investor should be charged in case of recovery
        require(registry[account].registrationHash != 0, "Account must be registered.");
        registry[account].recoverable = true;
        emit AskedForRecovery(account);
    }

    function setRecoveryPrice(uint256 price) public onlyOwners {
        recoveryPrice = price;
    }

    function recover(address oldAddress, address newAddress) public onlyOwners whenNotPaused {
        require(oldAddress != newAddress, "Old address cannot be the same as new address.");
        require(balanceOf(newAddress) == 0, "New address must not be in use.");
        require(registry[oldAddress].recoverable, "Old address not marked for recovery. Please ask for recovery first.");

        registry[newAddress] = registry[oldAddress];
        delete registry[oldAddress];
        emit Recovered(oldAddress);
    }
}


abstract contract Dividends is Registration {

    address[] private investorsList;
    mapping(address => bool) private eligibleInvestors;

    function payDividends() public payable onlyOwners returns (bool) {
        uint256 _amountPerToken = msg.value / totalSupply();
        for (uint32 i = 0; i < investorsList.length; i++) {
            if (registry[investorsList[i]].registrationHash != 0) {
                uint256 _dividend = shareBalanceOf(investorsList[i]) * _amountPerToken;
                payable(investorsList[i]).transfer(_dividend);
            }
        }
        return true;
    }

    function _update(address from, address to, uint256 amount) internal virtual override {
        super._update(from, to, amount);

        if (shareBalanceOf(from) > 0 && !eligibleInvestors[from] && registry[from].registrationHash != 0) {
            eligibleInvestors[from] = true;
            investorsList.push(from);
        }

        if (shareBalanceOf(to) > 0 && !eligibleInvestors[to] && registry[to].registrationHash != 0) {
            eligibleInvestors[to] = true;
            investorsList.push(to);
        }
    }
}


contract Share is Recovery, Offering, Dividends, Announcement {

    constructor() ERC20("Smart Contracts Lab Token", "SCLZ", 18) {
        addOwner(0x5a88f1E531916b681b399C33F519b7E2E54b5213); // Liam
        addOwner(0x3082f89471245a689bdd60EC82e6c12da97531d7); // Roman
        addOwner(0xb3A5E267F04acF7804E22A8600081f8B854e7847); // Laura
        addOwner(0xF85F88412589949dBfD6a70c76417AdBcf358249); // Patricia
        mint(msg.sender, 10000 * 1e18);
    }

    function _update(address from, address to, uint256 amount) internal override(Registry, Dividends) {
        super._update(from, to, amount);
    }
}
