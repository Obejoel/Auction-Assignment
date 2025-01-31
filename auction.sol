// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTAuction {

    ERC721 public nftContract;

    struct Auction {
        address seller;
        uint256 tokenId;
        uint256 startPrice;
        uint256 endTime; // To be calculated from the duration
        address highestBidder;
        uint256 higestBid;
        bool active;
    }

    uint256 private totalAuctions=0; 

    mapping(uint256 => Auction) public auctions;

    // Events
    event AuctionCreated(uint256 indexed tokenId, uint256 startPrice, uint256 endTime);
    event BidPlaced(uint256 tokenId, address bidder, uint256 amount);
    event AuctionFinalized(uint256 tokenId, address winner, uint256 amount);
    event AuctionCancelled(uint256 tokenId);

    constructor(address _nftContract) {
        nftContract = ERC721(_nftContract);
    }

    // Functions
    // create auction event
    // token is dynamically determined: using 'totalAuctions'
    function createAuction( uint256 _startPrice, uint256 _duration_in_days) external {
        Auction memory _auction = Auction({
            seller:msg.sender, 
            tokenId: totalAuctions,
            startPrice: _startPrice,
            // duraation is in days
            endTime: block.timestamp + (_duration_in_days * 84000),
            highestBidder: address(0),
            higestBid: 0,
            active: true
            });

            auctions[totalAuctions] = _auction;
            totalAuctions += 1;
    }

    // create bid
    function placeBid(uint256 _tokenId) external  payable {
        require(auctions[_tokenId].active, "Auction canceled");
        auctions[_tokenId].highestBidder = msg.sender;
        auctions[_tokenId].higestBid = msg.value;
    }

    // auction finalized
    function finalizeAuction(uint256 _tokenId) external {
        require(auctions[_tokenId].active, "Auction canceled");
        require(auctions[_tokenId].endTime < block.timestamp, "Auction has not ended");
        

    }
    
    // auction cancelled
    function cancelAuction(uint256 _tokenId) external {
        require(auctions[_tokenId].active, "Auction already canceled");
        auctions[_tokenId].active = false;
    }
}