// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface sakenToken2 {
    function balanceOf(address _account) external view returns (uint256);

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

contract Saken2 is sakenToken2 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 private MAXSupply;
    uint256 public tokenNormalPrice;
    uint256 public saleEndTime;
    uint256 public offerTokens;
    address private owner;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private tokenAllowance;

    event Transfer(address senders, address receivers, uint256 amount);
    event Approval(address owner, address tokenUser, uint256 amount);

    constructor(
        string memory _tokenName,
        string memory _tokensymbol,
        uint8 _decimal,
        uint256 _MAXSupply
    ) {
        owner = msg.sender;
        name = _tokenName;
        symbol = _tokensymbol;
        decimals = _decimal;
        MAXSupply = _MAXSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "saken2Sales: Only Owner can access");
        _;
    }

    function balanceOf(address _account) external view returns (uint256) {
        return balances[_account];
    }

    function transfer(address _to, uint256 _tokens) external returns (bool) {
        require(balances[msg.sender] >= _tokens, "saken2Sales: Failed!");
        balances[msg.sender] -= _tokens;
        balances[_to] += _tokens;
        emit Transfer(msg.sender, _to, _tokens);
        return true;
    }

    function approve(address _from, uint256 _tokens) external returns (bool) {
        require(
            balances[_from] >= _tokens,
            "saken2Sales: insuficient balance for approval"
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
            "saken2Sales: Not Allowed"
        );
        require(
            balances[_from] > 0 && balances[_from] >= _tokens,
            "saken2Sales: Failed!"
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

    function mint(uint256 _tokens) public onlyOwner {
        require(
            _tokens <= MAXSupply - totalSupply && _tokens > 0,
            "Saken2Sales: Reached MAX supply"
        );

        totalSupply += _tokens;
        // balances[owner] += _tokens;
        balances[address(this)] += _tokens;
        emit Transfer(address(0), owner, _tokens);
    }

    function burn(uint256 _tokens) external onlyOwner {
        totalSupply -= _tokens;
        // balances[owner] -= _tokens;
        balances[address(this)] -= _tokens;

        emit Transfer(owner, address(0), _tokens);
    }

    function setTokenPrice(uint256 _price) public onlyOwner {
        require(_price > 0, "Saken2Sales: Token price cannot be zero");

        tokenNormalPrice = _price;
    }


    function buyTokens(uint256 noOfTokens) external payable {
        bool offer;
        uint256 amountToBuy = msg.value;
        uint256 tokensPrice = tokenNormalPrice;
        require(tokensPrice > 0, "Saken2Sales: Token price is not set");
        if (block.timestamp <= saleEndTime && noOfTokens <= offerTokens) {
            require(msg.sender != owner, "Saken2Sales: You cannpt buy tokens");
                offerTokens -= noOfTokens;
                tokensPrice /= 2;
                offer = true;
        }
        require(
            amountToBuy == (noOfTokens * tokensPrice) / 10**decimals,
            "Saken2Sales: insufficient ethers to purchase"
        );
        require(
            noOfTokens <= balances[address(this)],
            "Saken2Sales: Not enough tokens in the reserve"
        );

        balances[msg.sender] += noOfTokens;
        balances[address(this)] -= noOfTokens;

        if (offer) {
            payable(owner).transfer(address(this).balance);
        }
        emit Transfer(address(this), msg.sender, noOfTokens);
    }

    function Withdraw_ContractBalance() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function set_PreSale(uint256 _saleTime) external onlyOwner {
        require(saleEndTime >= 0, "Saken2Sales: A sale is already running");
        require(tokenNormalPrice > 0, "Saken2Sales: Token price is not set");
        offerTokens = balances[address(this)] / 2;
        saleEndTime = block.timestamp + _saleTime;
    }
}
