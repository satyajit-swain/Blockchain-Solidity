// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ZeppERC20 is ERC20 {
    uint256 public tokenPrice;
    uint256 public maxSupply;
    address private owner;
    constructor(uint _maxSupply, uint _totalSupply, uint _tokenPrice) ERC20("saken","skn"){
        
        maxSupply = _maxSupply;

        require(_totalSupply <= _maxSupply, "ZeppERC20: Max token supply reach");
        _mint(msg.sender, _totalSupply);
        owner = msg.sender;
        tokenPrice = _tokenPrice;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "ZeppERC20: you are not the owner");
        _;
    }

    function mint(uint _tokens) public onlyOwner{
        require(_tokens <= maxSupply - totalSupply(), "ZeppERC20: Max token supply reach");
        _mint(msg.sender, _tokens);
        

    }

    function burn(uint _tokens) public onlyOwner{
        require(_tokens <= totalSupply() && _tokens > 0, "ZeppERC20: required token not available");
        _burn(msg.sender, _tokens);
        maxSupply -= _tokens;
        
        

    }
}