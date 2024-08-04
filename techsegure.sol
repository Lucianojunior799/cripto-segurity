// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TechSecure {
    string public name = "TechSecure";
    string public symbol = "TSEC";
    uint8 public decimals = 18; // 18 casas decimais
    uint256 public totalSupply;
    address public admin;
    bool private paused = false;

    // Fator de decimais para manipulação interna
    uint256 private constant DECIMALS_FACTOR = 10 ** 18;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => bool) private blacklist;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not the admin");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    modifier notBlacklisted(address _account) {
        require(!blacklist[_account], "Address is blacklisted");
        _;
    }

    constructor(uint256 _initialSupply) {
        admin = msg.sender;
        totalSupply = _initialSupply * DECIMALS_FACTOR;
        balances[admin] = totalSupply; // Atribui todo o supply inicial ao criador do contrato
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner] / DECIMALS_FACTOR;
    }

    function transfer(address _to, uint256 _value) public whenNotPaused notBlacklisted(msg.sender) notBlacklisted(_to) returns (bool) {
        require(_to != address(0), "Invalid address");
        uint256 amount = _value * DECIMALS_FACTOR;
        require(amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[_to] += amount;

        return true;
    }

    function approve(address _spender, uint256 _value) public whenNotPaused notBlacklisted(msg.sender) returns (bool) {
        allowances[msg.sender][_spender] = _value * DECIMALS_FACTOR;
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowances[_owner][_spender] / DECIMALS_FACTOR;
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused notBlacklisted(_from) notBlacklisted(_to) returns (bool) {
        require(_from != address(0) && _to != address(0), "Invalid address");
        uint256 amount = _value * DECIMALS_FACTOR;
        require(amount <= balances[_from], "Insufficient balance");
        require(amount <= allowances[_from][msg.sender], "Allowance exceeded");

        balances[_from] -= amount;
        balances[_to] += amount;
        allowances[_from][msg.sender] -= amount;

        return true;
    }

    // Funções restritas ao administrador

    function mint(uint256 _amount) public onlyAdmin whenNotPaused returns (bool) {
        uint256 amount = _amount * DECIMALS_FACTOR;
        totalSupply += amount;
        balances[admin] += amount;
        return true;
    }

    function burn(uint256 _amount) public onlyAdmin whenNotPaused returns (bool) {
        uint256 amount = _amount * DECIMALS_FACTOR;
        require(amount <= balances[admin], "Insufficient balance");
        totalSupply -= amount;
        balances[admin] -= amount;
        return true;
    }

    function pause() public onlyAdmin {
        paused = true;
    }

    function unpause() public onlyAdmin {
        paused = false;
    }

    function addToBlacklist(address _account) public onlyAdmin {
        blacklist[_account] = true;
    }

    function removeFromBlacklist(address _account) public onlyAdmin {
        blacklist[_account] = false;
    }

    function isBlacklisted(address _account) public view returns (bool) {
        return blacklist[_account];
    }
}
