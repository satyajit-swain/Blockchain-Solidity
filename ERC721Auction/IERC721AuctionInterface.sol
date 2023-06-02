// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface IERC721AuctionInterface {
    struct Auction {
        address seller;
        uint256 tokenId;
        uint256 startPrice;
        uint256 startTime;
        uint256 endTime;
        uint256 highestBid;
        address highestBidder;
        bool activeAuction;
    }
    struct Bidders{
        address bidderAddr;
        uint256 priceBid;
    }

    function createAuction(
        uint256 _tokenId,
        uint256 _startPrice,
        uint256 _startTime,
        uint256 _duration
    ) external;

    function placeBid(uint256 _tokenId) external payable;

    function endAuction(uint256 _tokenId) external;

    function claimToken(uint256 _tokenId) external;

    event AuctionCreated(
        address seller,
        uint256 tokenId,
        uint256 startPrice,
        uint256 startTime,
        uint256 endTime
    );
    event BidPlaced(address bidder, uint256 tokenId, uint256 bidAmount);
    event AuctionEnded(
        address seller,
        uint256 tokenId
    );
    event TokenClaimed(address highestBidder, uint256 tokenId, uint256 highestBid);
    event BidCancelation(address BidCanceler, uint256 tokenId);

}
