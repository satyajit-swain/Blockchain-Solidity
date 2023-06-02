// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./ERC1155Token.sol";

contract ERC1155MarketPlace {
    address private erc1155;

    struct tokenOnSale {
        uint256 quantity;
        uint256 tokenPrice;
        address seller;
        bool isOnSale;
    }

    mapping(uint256 => mapping(address => tokenOnSale)) public onSale;

    constructor(address _erc1155) {
        erc1155 = _erc1155;
    }

    function setOnSale(
        uint256 _tokenId,
        uint256 _quantity,
        uint256 _price
    ) public {
        require(_price > 0, "ERC1155MarketPlace: invalid price");
        require(_quantity > 0, "ERC1155MarketPlace: invalid quantity");
        require(
            !onSale[_tokenId][msg.sender].isOnSale,
            "ERC1155MarketPlace: Already in sale"
        );
        require(
            ERC1155Token(erc1155).isApprovedForAll(msg.sender, address(this)),
            "TokenMarketPlace: not approved"
        );
        _setonSale(_tokenId, _quantity, _price);
    }

    function _setonSale(
        uint256 _tokenId,
        uint256 _quantity,
        uint256 _price
    ) internal {
        onSale[_tokenId][msg.sender].tokenPrice = _price;
        onSale[_tokenId][msg.sender].quantity += _quantity;
        onSale[_tokenId][msg.sender].seller = msg.sender;
        onSale[_tokenId][msg.sender].isOnSale = true;
    }

    function setBatchOnSale(
        uint256[] memory _tokenIds,
        uint256[] memory _quantities,
        uint256[] memory _price
    ) external {
        require(
            _tokenIds.length == _quantities.length &&
                _quantities.length == _price.length,
            "ERC1155MarketPlace: all three inputs needed to be of same length"
        );
        for (uint256 index = 0; index < _tokenIds.length; index++) {
            require(
                _price[index] > 0,
                "ERC1155MarketPlace: price must be positive"
            );
            require(
                !onSale[_tokenIds[index]][msg.sender].isOnSale,
                "ERC155Market: token already in sale"
            );
            _setonSale(_tokenIds[index], _quantities[index], _price[index]);
        }
    }

    function buy(
        uint256 _tokenId,
        uint256 _quantity,
        address _sellerAddress
    ) external payable {
        require(
            onSale[_tokenId][_sellerAddress].isOnSale,
            "ERC1155MarketPlace: token not on sale"
        );
        require(
            msg.sender != onSale[_tokenId][_sellerAddress].seller,
            "ERC1155MarketPlace: you are the seller"
        );

        require(
            _quantity > 0 &&
                _quantity <= onSale[_tokenId][_sellerAddress].quantity,
            "ERC1155MarketPlace: invalid amount"
        );
        require(
            msg.value ==
                _quantity * onSale[_tokenId][_sellerAddress].tokenPrice,
            "ERC1155MarketPlace: invalid price"
        );
        ERC1155Token(erc1155).safeTransferFrom(
            onSale[_tokenId][_sellerAddress].seller,
            msg.sender,
            _tokenId,
            _quantity,
            bytes("Purchased")
        );
        onSale[_tokenId][_sellerAddress].quantity -= _quantity;
        if (onSale[_tokenId][_sellerAddress].quantity == 0) {
            delete onSale[_tokenId][_sellerAddress];
        }
    }

    function stopSale(uint256 _tokenId) external {
        require(
            onSale[_tokenId][msg.sender].isOnSale,
            "ERC1155MarketPlace: not on sale"
        );
        require(
            onSale[_tokenId][msg.sender].seller == msg.sender,
            "ERC1155MarketPlace: you're not the seller"
        );
        delete onSale[_tokenId][msg.sender];
    }
}
