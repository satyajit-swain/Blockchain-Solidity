// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../ERC1155/ERC1155Token.sol";
import "./IERC1155AuctionInterface.sol";



contract ERC1155TokenAuction is IERC1155AuctionInterface {
    address private erc1155;

    mapping(uint256 => mapping(address => Auction)) public auction;
    mapping(uint256 => mapping(address =>Bidders[])) private bidder;
    mapping(address => mapping(address =>uint256)) private bidderAmounts;

    constructor(address _erc1155) {
        erc1155 = _erc1155;
    }

    function createAuction(
        uint256 _tokenId,
        uint256 _quantity,
        uint256 _startPrice,
        uint256 _startTime,
        uint256 _duration
    ) external {

        require(
            _quantity <= ERC1155Token(erc1155).balanceOf(msg.sender, _tokenId),
            "ERC1155TokenAuction: Not enough tokens"
        );
        require(
            ERC1155Token(erc1155).balanceOf(msg.sender, _tokenId) == _quantity,
            "ERC1155TokenAuction: Not enough token balance"
        );

        require(
            ERC1155Token(erc1155).isApprovedForAll(msg.sender, address(this)),
            "ERC1155TokenAuction: not approved"
        );

        require(
            _startTime > block.timestamp || _startTime == 0,
            "ERC1155TokenAuction: invalid time"
        );

        require(
            _startPrice > 0,
            "ERC1155TokenAuction: starting price must be greater than zero."
        );

        ERC1155Token(erc1155).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId,
            _quantity,
            "Tokens are in Auction"
        );

        auction[_tokenId][msg.sender] = Auction({
            seller: msg.sender,
            tokenId: _tokenId,
            quantity: _quantity,
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
            _quantity,
            _startPrice,
            block.timestamp + _startTime,
            block.timestamp + _duration
        );
    }

    function placeBid(uint256 _tokenId, address _tokenSeller) external payable {
        require(
            auction[_tokenId][_tokenSeller].activeAuction,
            "ERC1155TokenAuction: Auction is not active"
        );
        require(
            block.timestamp < auction[_tokenId][_tokenSeller].endTime,
            "ERC1155TokenAuction: Auction has ended"
        );
        require(
            msg.sender != auction[_tokenId][_tokenSeller].seller,
            "ERC1155TokenAuction: You cannot bid"
        );
        require(
            msg.value > auction[_tokenId][_tokenSeller].highestBid,
            "ERC1155TokenAuction: Bid amount must be higher than the current highest bid"
        );

        bidder[_tokenId][_tokenSeller].push(Bidders(msg.sender, msg.value));
        bidderAmounts[msg.sender][_tokenSeller] += msg.value;
        auction[_tokenId][_tokenSeller].highestBidder = msg.sender;
        auction[_tokenId][_tokenSeller].highestBid = msg.value;

        emit BidPlaced(msg.sender, _tokenId, _tokenSeller, msg.value);
    }

    function endAuction(uint256 _tokenId, address _tokenSeller) external {
        require(
            msg.sender == auction[_tokenId][_tokenSeller].seller,
            "ERC1155TokenAuction: Only the seller can perform this action"
        );
        require(
            auction[_tokenId][_tokenSeller].activeAuction,
            "ERC1155TokenAuction: Auction is not active"
        );
        require(
            block.timestamp >= auction[_tokenId][_tokenSeller].endTime,
            "ERC1155TokenAuction: Auction has not ended yet"
        );

        auction[_tokenId][_tokenSeller].activeAuction = false;

        if (auction[_tokenId][_tokenSeller].highestBid > 0) {
            payable(_tokenSeller).transfer(
                auction[_tokenId][_tokenSeller].highestBid
            );
        } else {
            ERC1155Token(erc1155).safeTransferFrom(
                address(this),
                _tokenSeller,
                _tokenId,
                auction[_tokenId][_tokenSeller].quantity,
                "tokens transfered"
            );
        }

        delete auction[_tokenId][_tokenSeller];

        emit AuctionEnded(_tokenSeller, _tokenId);
    }

    function claimToken(uint256 _tokenId, address _tokenSeller) external {
        require(
            msg.sender == auction[_tokenId][_tokenSeller].highestBidder,
            "ERC1155TokenAuction: You're not the highest bidderArray"
        );

        require(
            block.timestamp >= auction[_tokenId][_tokenSeller].endTime,
            "ERC1155TokenAuction: Auction has not ended yet"
        );

        ERC1155Token(erc1155).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId,
            auction[_tokenId][_tokenSeller].quantity,
            "tokens transferd"
        );

        for (uint256 index = 0; index < bidder[_tokenId][_tokenSeller].length; index++) {
            if (bidder[_tokenId][_tokenSeller][index].bidderAddr != msg.sender) {
                payable(bidder[_tokenId][_tokenSeller][index].bidderAddr).transfer(
                    bidderAmounts[bidder[_tokenId][_tokenSeller][index].bidderAddr][_tokenSeller]
                );
            }
        }

        emit TokenClaimed(msg.sender, _tokenId, _tokenSeller, auction[_tokenId][_tokenSeller].highestBid);
    }

    function cancelBid(uint256 _tokenId, address _tokenSeller) external {
        require(
            bidderAmounts[msg.sender][_tokenSeller] > 0,
            "ERC1155TokenAuction: You haven't bid yet"
        );
        payable(msg.sender).transfer(bidderAmounts[msg.sender][_tokenSeller]);

        for (uint256 index = 0; index < bidder[_tokenId][_tokenSeller].length; index++) {
            if (msg.sender == bidder[_tokenId][_tokenSeller][index].bidderAddr) {
                for (
                    uint256 indexs = 0;
                    indexs < bidder[_tokenId][_tokenSeller].length - 1;
                    indexs++
                ) {
                    bidder[_tokenId][_tokenSeller][indexs] = bidder[_tokenId][_tokenSeller][indexs + 1];
                }
                bidder[_tokenId][_tokenSeller].pop();
            }
        }

        emit BidCancelation(msg.sender, _tokenId, _tokenSeller);
    }
}
