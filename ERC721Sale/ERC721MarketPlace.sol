// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "ERC721Sale/ERC721Token.sol";

contract ERC721MarketPlace {
    address erc721;
    uint256 public numOfTokensOnSale;

    struct tokenOnSale {
        uint256 tokenId;
        uint256 tokenPrice;
        address tokenOwner;
        bool isOnSale;
    }
    
    mapping(uint256 => tokenOnSale) public onSale;

    constructor(address _erc721) {
        erc721 = _erc721;
    }

    function setOnSale(uint256 _tokenId, uint256 _tokenPrice) public {
        require(
            ERC721Token(erc721).ownerOf(_tokenId) == msg.sender,
            "ERC721MarketPlace: not token owner"
        );
        require(_tokenPrice > 0, "ERC721MarketPlace: invalid token price");
        require(
            !onSale[_tokenId].isOnSale,
            "ERC721MarketPlace: token already on Sale"
        );
        require(
            ERC721Token(erc721).getApproved(_tokenId) == address(this) ||
                ERC721Token(erc721).isApprovedForAll(msg.sender, address(this)),
            "ERC721MarketPlace: not approved"
        );
        onSale[_tokenId].tokenId = _tokenId;
        onSale[_tokenId].tokenPrice = _tokenPrice;
        onSale[_tokenId].tokenOwner = msg.sender;
        onSale[_tokenId].isOnSale = true;
        numOfTokensOnSale++;
    }

    function buy(uint256 _tokenId) public payable {
        require(
            onSale[_tokenId].isOnSale,
            "ERC721MarketPlace: token not in sale"
        );
        require(
            onSale[_tokenId].tokenPrice == msg.value,
            "ERC721MarketPlace: invalid Price"
        );
        ERC721Token(erc721).transferFrom(
            onSale[_tokenId].tokenOwner,
            msg.sender,
            _tokenId
        );
        delete onSale[_tokenId];
    }

    function setEndSale(uint256 _tokenId) public {
        require(
            onSale[_tokenId].isOnSale,
            "ERC721MarketPlace: token not in sale"
        );
        require(
            onSale[_tokenId].tokenOwner == msg.sender,
            "ERC721MarketPlace: not token owner"
        );
        delete onSale[_tokenId];
    }
}
