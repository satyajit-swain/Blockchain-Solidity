// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface sakenToken { 
    function balanceOf(address _userAddress) external view returns (uint256);
    function transfer(address _to, uint256 _tokens)
        external
        returns (bool);
    function approve(address _from, uint256 _tokens)
        external 
        returns (bool);
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokens
    ) external  returns (bool);
     function allowance(address _owner, address _from)
        external 
        view
        returns (uint256);
    function mint(uint256 _tokens) external ;
    function burn(uint256 _tokens) external ;

    
}
contract Saken {
    string public name;
    string public symbol;
    uint8 public decimal;
    uint256 public totalSupply;
    address internal owner;

    mapping(address => uint256) userBalances;
    mapping(address => mapping(address => uint256)) tokenAllowance;

    event TransferToken(address senders, address receivers, uint256 amount);
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
        userBalances[msg.sender] = _totalSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner can access");
        _;
    }

    function balanceOf(address _userAddress) public view returns (uint256) {
        require(_userAddress != address(0), "Invalid address!");
        return userBalances[_userAddress];
    }

    function transfer(address _to, uint256 _tokens)
        public
        returns (bool)
    {
        require(
            userBalances[msg.sender] > 0 && userBalances[msg.sender] >= _tokens,
            "Failed!"
        );
        userBalances[msg.sender] -= _tokens;
        userBalances[_to] += _tokens;
        emit TransferToken(msg.sender, _to, _tokens);
        return true;
    }

    function approve(address _from, uint256 _tokens)
        public
        returns (bool)
    { 
        //TODO : if unsufficient balance to give allowance 
        tokenAllowance[msg.sender][_from] = _tokens;
        emit Approval(msg.sender, _from, _tokens);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokens
    ) public returns (bool) {
        require(tokenAllowance[_from][msg.sender] >= _tokens, "Not Allowed");
        require(
            userBalances[_from] > 0 && userBalances[_from] >= _tokens,
            "Failed!"
        );
        userBalances[_from] -= _tokens;
        userBalances[_to] += _tokens;
        tokenAllowance[msg.sender][_from] -= _tokens;
        emit TransferToken(_from, _to, _tokens);
        return true;
    }

    function allowance(address _owner, address _from)
        public
        view
        returns (uint256)
    {
        return tokenAllowance[_owner][_from];
    }

    function mint(uint256 _tokens) public onlyOwner {
        totalSupply += _tokens;
        userBalances[owner] += _tokens;
    }

    function burn(uint256 _tokens) public onlyOwner {
        totalSupply -= _tokens;
        userBalances[owner] -= _tokens;
    }
}
