// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERC721 {
    function transferFrom(address _from, address _to, uint nftId) external;
}


contract EnglishAuction{
    // Events //
    event Start();
    event Bid(address indexed _from, uint amount);
    event Withdraw(address indexed _from, uint amount);
    event End(address highestBidder, uint amount)

    //State Variables//
    IERC721 public immutable nft;
    address payable public immutable seller;
    uint256 public immutable nftId;
    uint256 public highestBid;

    uint32 public immutable endAt;

    bool public started;
    bool public ended;

    address public highestBidder;
    uint256 public highestBid;
    mapping(address => uint256) bids // Address -> Amount bid thats not highest bidder

    constructor(
        address _nft,
        uint256 _nftId,
        uint256 _startingBid
    ) {
        nft = IERC721(_nft);
        nftId = _nftId;
        highestBid = _startingBid;
        seller = payable(msg.sender);
    }

    function start() external {
        require(msg.owner == seller, "not seller");
        require(!started, "started");
        
        started = true;
        endAt = uint32(block.timestamp + 60);
        nft.transferFrom(seller, address(this), nftId);
        emit Start();
    }

    function bid() external payable {
        require(started, "not started");
        require(block.timestamp < endAt, "ended");
        require(msg.value > highestBid, "value < highest bid");
        
        // Tracks all bids that were outbid to withdraw later
        if (highestBidder != address(0)) {
        bids[highestBidder] += highestBid;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;

        event Bid(msg.sender, msg.value);
    }

    function withdraw() external payable{
        uint bal = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(bal);
        emit withdraw(msg.sender, bal);
    }

    function end() external {
        require(started, "not started");
        require(!ended, "ended");
        require(block.timestamp >= endAt, "ended");

        ended = true;

        if(highestBidder != address(0)) {
        nft.transferFrom(address(this), highestBidder, nftId);
        seller.transfer(highestBid);
        } 
        else {
        nft.transferFrom(address(this), seller, nftId);
        emit End(highestBidder, highestBid);
        }
    }


}
