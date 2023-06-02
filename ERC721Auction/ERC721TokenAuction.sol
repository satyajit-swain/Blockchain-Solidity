// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "../ERC721/ERC721Token.sol";
import "./IERC721AuctionInterface.sol";

contract ERC721TokenAucton is IERC721AuctionInterface {
    address erc721;
    mapping(uint256 => Auction) public auction;
    mapping(uint256 => Bidders[]) private bidder;
    mapping(address => uint256) private bidderAmounts;

    constructor(address _erc721) {
        erc721 = _erc721;
    }

    function createAuction(
        uint256 _tokenId,
        uint256 _startPrice,
        uint256 _startTime,
        uint256 _duration
    ) external {
        require(
            ERC721Token(erc721).ownerOf(_tokenId) == msg.sender,
            "ERC721TokenAuction: You must own the token to create an auction"
        );
        require(
            !auction[_tokenId].activeAuction,
            "ERC721TokenAuction: There is a active auction"
        );
        require(
            _startPrice > 0,
            "ERC721TokenAuction: starting price must be greater than zero."
        );
        require(
            _startTime > block.timestamp || _startTime == 0,
            "ERC721TokenAuction: invalid time"
        );
        require(
            ERC721Token(erc721).getApproved(_tokenId) == address(this) ||
                ERC721Token(erc721).isApprovedForAll(msg.sender, address(this)),
            "ERC721TokenAuction: not approved"
        );

        ERC721Token(erc721).transferFrom(msg.sender, address(this), _tokenId);

        auction[_tokenId] = Auction({
            seller: msg.sender,
            tokenId: _tokenId,
            startPrice: _startPrice,
            startTime: block.timestamp + _startTime,
            endTime: block.timestamp + _duration,
            activeAuction: true,
            highestBidder: address(0),
            highestBid: 0
        });

        emit AuctionCreated(
            msg.sender,
            _tokenId,
            _startPrice,
            block.timestamp + _startTime,
            block.timestamp + _duration
        );
    }

    function placeBid(uint256 _tokenId) external payable {
        require(
            auction[_tokenId].activeAuction,
            "ERC721TokenAuction: Auction is not active"
        );
        require(
            block.timestamp < auction[_tokenId].endTime,
            "ERC721TokenAuction: Auction has ended"
        );
        require(
            msg.sender != auction[_tokenId].seller,
            "ERC721TokenAuction: You cannot bid"
        );
        require(
            msg.value > auction[_tokenId].highestBid,
            "ERC721TokenAuction: Bid amount must be higher than the current highest bid"
        );

        bidder[_tokenId].push(Bidders(msg.sender, msg.value));
        bidderAmounts[msg.sender] += msg.value;
        auction[_tokenId].highestBidder = msg.sender;
        auction[_tokenId].highestBid = msg.value;

        emit BidPlaced(msg.sender, _tokenId, msg.value);
    }

    function endAuction(uint256 _tokenId) external {
        require(
            msg.sender == auction[_tokenId].seller,
            "ERC721TokenAuction: Only the seller can perform this action"
        );
        require(
            auction[_tokenId].activeAuction,
            "ERC721TokenAuction: Auction is not active"
        );
        require(
            block.timestamp >= auction[_tokenId].endTime,
            "ERC721TokenAuction: Auction has not ended yet"
        );

        auction[_tokenId].activeAuction = false;

        if (auction[_tokenId].highestBid > 0) {
            payable(auction[_tokenId].seller).transfer(
                auction[_tokenId].highestBid
            );
        } else {
            ERC721Token(erc721).transferFrom(
                address(this),
                auction[_tokenId].seller,
                _tokenId
            );
        }

        delete auction[_tokenId];

        emit AuctionEnded(auction[_tokenId].seller, _tokenId);
    }

    function claimToken(uint256 _tokenId) external {
        require(
            msg.sender == auction[_tokenId].highestBidder,
            "ERC721TokenAuction: You're not the highest bidderArray"
        );

        require(
            block.timestamp >= auction[_tokenId].endTime,
            "ERC721TokenAuction: Auction has not ended yet"
        );

        ERC721Token(erc721).transferFrom(address(this), msg.sender, _tokenId);

        for (uint256 index = 0; index < bidder[_tokenId].length; index++) {
            if (bidder[_tokenId][index].bidderAddr != msg.sender) {
                payable(bidder[_tokenId][index].bidderAddr).transfer(
                    bidderAmounts[bidder[_tokenId][index].bidderAddr]
                );
            }
        }

        emit TokenClaimed(msg.sender, _tokenId, auction[_tokenId].highestBid);
    }

    function cancelBid(uint256 _tokenId) public {
        require(
            bidderAmounts[msg.sender] > 0,
            "ERC721TokenAuction: You haven't bid yet"
        );
        payable(msg.sender).transfer(bidderAmounts[msg.sender]);

        for (uint256 index = 0; index < bidder[_tokenId].length; index++) {
            if (msg.sender == bidder[_tokenId][index].bidderAddr) {
                for (
                    uint256 indexs = 0;
                    indexs < bidder[_tokenId].length - 1;
                    indexs++
                ) {
                    bidder[_tokenId][indexs] = bidder[_tokenId][indexs + 1];
                }
                bidder[_tokenId].pop();
            }
        }

        emit BidCancelation(msg.sender, _tokenId);
    }
}
