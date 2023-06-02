// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ITokenMarketPlace {
    struct TokenOnSale {
        address seller;
        uint256 tokenId;
        uint256 quantity;
        uint256 tokenPrice;
        bool isOnSale;
        uint256 tokenType;
    }

    struct Auction {
        address seller;
        uint256 tokenId;
        uint256 quantity;
        uint256 startPrice;
        uint256 startTime;
        uint256 endTime;
        uint256 highestBid;
        address highestBidder;
        bool activeAuction;
    }

    struct Bidders {
        address bidderAddr;
        uint256 priceBid;
    }

    event SaleSet(
        address seller,
        uint256 tokenId,
        uint256 tokenPrice,
        uint256 quantity
    );
    event TokenPurchased(
        address buyer,
        uint256 tokenId,
        uint256 quantity,
        address tokenSeller
    );
    event AuctionCreated(
        address seller,
        uint256 tokenId,
        uint256 quantity,
        uint256 startPrice,
        uint256 startTime,
        uint256 endTime
    );
    event BidPlaced(
        address bidder,
        uint256 tokenId,
        address tokenSeller,
        uint256 bidAmount
    );
    event SaleEnded(address seller, uint256 tokenId);
    event AuctionEnded(address seller, uint256 tokenId);
    event TokenClaimed(
        address highestBidder,
        uint256 tokenId,
        address tokenSeller,
        uint256 highestBid
    );
    event BidCancelation(
        address BidCanceler,
        uint256 tokenId,
        address tokenSeller
    );

    function setOnSale(
        uint256 _tokenId,
        uint256 _tokenPrice,
        uint256 _quantity,
        uint256 _tokenType
    ) external;

    function buy(
        uint256 _tokenId,
        uint256 _tokenType,
        uint256 _quantity,
        address _sellerAddress
    ) external payable;

    function stopSale(uint256 _tokenId, uint256 _tokenType) external;

    function createAuction(
        uint256 _tokenType,
        uint256 _tokenId,
        uint256 _quantity,
        uint256 _startPrice,
        uint256 _startTime,
        uint256 _duration
    ) external;

    function placeBid(
        uint256 _tokenId,
        uint256 _tokenType,
        address _tokenSeller
    ) external payable;

    function cancelAuction(
        uint256 _tokenId,
        address _tokenSeller,
        uint256 _tokenType
    ) external;

    function claimToken(
        uint256 _tokenId,
        address _tokenSeller,
        uint256 _tokenType
    ) external;

    function cancelBid(
        uint256 _tokenId,
        address _tokenSeller,
        uint256 _tokenType
    ) external;
}
