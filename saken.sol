// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface sakenToken {
    function balance() external view returns (uint256);

    function transfer(address _to, uint256 _tokens) external returns (bool);

    function approve(address _from, uint256 _tokens) external returns (bool);

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokens
    ) external returns (bool);

    function allowance(address _owner, address _from)
        external
        view
        returns (uint256);

    function mint(uint256 _tokens) external;

    function burn(uint256 _tokens) external;
}

contract Saken {
    string public name;
    string public symbol;
    uint8 public decimal;
    uint256 public totalSupply;
    address internal owner;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) tokenAllowance;

    event Transfer(address senders, address receivers, uint256 amount);
    event Approval(address owner, address tokenUser, uint256 amount);

    constructor(
        string memory _tokenName,
        string memory _tokensymbol,
        uint256 _totalSupply,
        uint8 _decimal
    ) {
        owner = msg.sender;
        name = _tokenName;
        symbol = _tokensymbol;
        decimal = _decimal;
        totalSupply = _totalSupply;
        balances[msg.sender] = _totalSupply;
        mint(_totalSupply);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "saken: Only Owner can access");
        _;
    }

    function balance() external view returns (uint256) {
        return balances[msg.sender];
    }

    function transfer(address _to, uint256 _tokens) external returns (bool) {
        require(balances[msg.sender] >= _tokens, "saken: Failed!");
        balances[msg.sender] -= _tokens;
        balances[_to] += _tokens;
        emit Transfer(msg.sender, _to, _tokens);
        return true;
    }

    function approve(address _from, uint256 _tokens) external returns (bool) {
        require(
            balances[_from] >= _tokens,
            "saken: insuficient balance for approval"
        );

        tokenAllowance[msg.sender][_from] = _tokens;
        emit Approval(msg.sender, _from, _tokens);

        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokens
    ) external returns (bool) {
        require(
            tokenAllowance[_from][msg.sender] >= _tokens,
            "saken: Not Allowed"
        );
        require(
            balances[_from] > 0 && balances[_from] >= _tokens,
            "saken: Failed!"
        );
        balances[_from] -= _tokens;
        balances[_to] += _tokens;
        tokenAllowance[_from][msg.sender] -= _tokens;
        emit Transfer(_from, _to, _tokens);
        return true;
    }

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256)
    {
        return tokenAllowance[_owner][_spender];
    }

    function mint(uint256 _tokens) internal onlyOwner {
        totalSupply += _tokens;
        balances[owner] += _tokens;
        emit Transfer(address(0), owner, _tokens);
    }

    function burn(uint256 _tokens) external onlyOwner {
        totalSupply -= _tokens;
        balances[owner] -= _tokens;
        emit Transfer(owner, address(0), _tokens);
    }
}
