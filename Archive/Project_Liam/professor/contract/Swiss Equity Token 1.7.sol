// *******************************************
// SPDX-License-Identifier: MIT
// Swiss Equity Token 1.7
// Author: Smart Contracts Lab, University of Zurich
// Created: June 29, 2023
// *******************************************

pragma solidity ^0.8.18;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address to, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address from, address to, uint amount) external returns (bool);
}

contract SwissEquityToken is IERC20 {

    event Registered(address indexed account, bytes32 hash, bool recoverable);
    event Recovered(address indexed oldAccount, address indexed newAccount);

    struct Investor {
        uint balance;
        uint shares;
        uint fractions;
        bool known;
        uint ID;
        bytes32 hash;
        bool recoverable;
        address[] approvalsFrom;
    }

    mapping(address => Investor) private _registry;
    mapping(address => mapping(address => uint)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private immutable _decimals;
    uint private _totalSupply;

    uint public _totalShares;
    address public _issuer;
    address public _deputy;
    uint public immutable _ONE_SHARE;
    uint public _treasuryShares; // owned by issuer but inaccessible
    bool public _paused;
    uint private _counterID;

    modifier onlyIssuer() {
        require((msg.sender == _issuer) || (msg.sender == _deputy), "only issuer");
        _;
    }

    constructor() {
        _name = "Swiss Equity Token";
        _symbol = "SET";
        _decimals = 18;
        _ONE_SHARE = 10 ** _decimals;
        _totalShares = 10000000;
        _totalSupply = _totalShares * _ONE_SHARE;
        _issuer = msg.sender;
        _deputy = 0x41EaC9c0E5EA02ae690f37CdA6fB1cdDECD752b1;
        _registry[_issuer].ID = 0;
        _registry[_issuer].balance = _totalSupply;
        _registry[_issuer].shares = _totalShares;
        _registry[_issuer].known = true;
        _counterID = 1;
    }

// ************************* ERC20 Module *************************

    function name() public virtual view returns (string memory) {return _name;}

    function symbol() public virtual view returns (string memory) {return _symbol;}

    function decimals() public virtual view returns (uint8) {return _decimals;}

    function totalSupply() public virtual view returns (uint)  {return _totalSupply;}

    function balanceOf(address owner) public virtual view returns (uint) {return _registry[owner].balance;}

    function transfer(address to, uint value) public virtual returns (bool) {
        settleTransfer(msg.sender, to, value);
        return(true);
    }

    function allowance(address owner, address spender) public virtual view returns (uint) {return _allowances[owner][spender];}

    function approve(address spender, uint value) public virtual returns (bool) {
        _allowances[msg.sender][spender] = value;
        _registry[spender].approvalsFrom.push(msg.sender);
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public virtual returns (bool) {
        require(value <= _allowances[from][msg.sender], "allowance too low");
        settleTransfer(from, to, value);
        _allowances[from][msg.sender] -= value;
        if (_allowances[from][msg.sender] == 0) {
            for (uint i = 0; i < _registry[msg.sender].approvalsFrom.length; i++) {
                if (_registry[msg.sender].approvalsFrom[i] == from) {
                    delete _registry[msg.sender].approvalsFrom[i];
                    break;
                }
            }
        }
        return true;
    }

// ************************* Shareholder Module *************************

    function sharesOf(address owner) public view returns (uint) {return _registry[owner].shares;}

    function fractionsOf(address owner) public view returns (uint) {return _registry[owner].fractions;}

    function transferShares(address to, uint shares) public returns (bool) {
        settleTransfer(msg.sender, to, shares * _ONE_SHARE);
        return(true);
    }

    function register(bytes32 hash, bool recoverable) public {
        require(_registry[msg.sender].known == false, "You have already registered.");
        _registry[msg.sender].hash = hash;
        _registry[msg.sender].recoverable = recoverable;
        _registry[msg.sender].ID = _counterID;
        _counterID += 1;
        _registry[msg.sender].known = true;
        emit Registered(msg.sender, hash, recoverable);
    }

// ************************* Settlement Module *************************

    function settleTransfer(address from, address to, uint value) internal {
        require(_paused == false, "paused");
        require(value <= _registry[from].balance, "balance too low");

        uint _shares = value / _ONE_SHARE;
        uint _fractions = value % _ONE_SHARE;
        uint _checkSum = _treasuryShares + _registry[from].shares + _registry[to].shares;

        _registry[from].balance -= value; // debit
        _registry[to].balance += value; // credit

        if (_fractions > _registry[from].fractions) { // insufficient fractions to settle debit: one share is swapped into fractions
            _registry[from].shares -= 1;
            _treasuryShares += 1;
            _registry[from].fractions += _ONE_SHARE;
        }

        _registry[from].shares -= _shares;
        _registry[to].shares += _shares;
        _registry[from].fractions -= _fractions;
        _registry[to].fractions += _fractions;

        if (_registry[to].fractions >= _ONE_SHARE) { // too many fractions resulting from credit: swap is reversed
            _registry[to].shares += 1;
            _treasuryShares -= 1;
            _registry[to].fractions -= _ONE_SHARE;
        }

        assert(_registry[from].shares == _registry[from].balance / _ONE_SHARE);
        assert(_registry[from].fractions == _registry[from].balance % _ONE_SHARE);
        assert(_registry[to].shares == _registry[to].balance / _ONE_SHARE);
        assert(_registry[to].fractions == _registry[to].balance % _ONE_SHARE);
        assert(_checkSum == _treasuryShares + _registry[from].shares + _registry[to].shares);

        emit Transfer(from, to, value);
    }

// ************************* Issuer Module *************************

    function numberOfInvestors() public view returns(uint) {return _counterID + 1;}

    function pause() public onlyIssuer {_paused = true;}

    function unpause() public onlyIssuer {_paused = false;}

    function recover(address oldAccount, address newAccount) public onlyIssuer {
        require(_registry[oldAccount].recoverable, "not recoverable");

        _registry[newAccount] = _registry[oldAccount];

        for (uint i = 0; i < _registry[oldAccount].approvalsFrom.length; i++) {
            address authorizer = _registry[oldAccount].approvalsFrom[i];
            _allowances[authorizer][newAccount] = _allowances[authorizer][oldAccount];
            delete _allowances[authorizer][oldAccount];
        }

        delete _registry[oldAccount];
        emit Recovered(oldAccount, newAccount);
    }

    function raise(uint shares) public onlyIssuer {
        uint _value = shares * _ONE_SHARE;
        _registry[_issuer].balance += _value;
        _registry[_issuer].shares += shares;
        _totalSupply += _value;
        _totalShares += shares;
        emit Transfer(address(0), _issuer, _value);
    }

    function changeDeputy(address deputy) public onlyIssuer { _deputy = deputy; }

    function changeIssuer(address issuer) public onlyIssuer { _issuer = issuer; }
}
