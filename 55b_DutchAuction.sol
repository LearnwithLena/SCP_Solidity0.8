// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.10;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;
}

/**
 * @title Dutch Auction
 * @author SCF/ Lena
 * @notice This contract auctions an nft based on a discount rate and a time lapse.
 */

contract DutchAuction {
    uint public constant DURATION = 7 days;

    IERC721 public immutable nft;
    uint public immutable tokenId;
    address payable public immutable seller;
    uint public immutable startTime;
    uint public immutable endTime;
    uint public immutable startingPrice;
    uint public immutable discountRate;

    constructor(
        uint _tokenId,
        uint _startingPrice,
        uint _discountRate,
        address _nft
    ) {
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        discountRate = _discountRate;
        startTime = block.timestamp;
        endTime = block.timestamp + DURATION;

        require(
            startingPrice >= _discountRate * DURATION,
            "startprice < discount"
        );

        nft = IERC721(_nft);
        tokenId = _tokenId;
    }

    function getPrice() public view returns (uint) {
        uint timePassed = block.timestamp - startTime; // time passed = start time - now
        uint discount = discountRate * timePassed; // discount = discount rate * time passed
        uint price = startingPrice - discount; // price now = startprice - discount
        return price;
    }

    function buy() external payable {
        require(block.timestamp < endTime, "Auction expired");
        uint price = getPrice();

        require(msg.value >= price, "not enough eth sent");

        nft.transferFrom(seller, msg.sender, tokenId);

        uint refund = msg.value - price;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }

        selfdestruct(seller);
    }
}
