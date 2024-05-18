// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./IERC20.sol";

/**
 * Title: CrowdFund
 * Author: SCP/ Lena
 * Notice: A contract that crowdfunds based on a target amount. If the target is reached, then the amount is claimed, otherwise the amounts are refunded to the donors.
 */

contract CrowdFund {
    // Events //
    event Launch(
        uint count,
        address sender,
        uint _goal,
        uint32 _startAt,
        uint32 _endAt
    );
    event Pledge(uint id, address indexed sender, uint amount);
    event Cancel(uint id);
    event UnPledge(uint id, address indexed sender, uint _amount);
    event Claimed(uint id, uint amount);
    event Refund(uint indexed id, address indexed sender, uint amount);

    // Struct for details about the campaign
    struct Campaign {
        address creator;
        uint goal;
        uint pledged;
        uint32 startAt;
        uint32 endAt;
        bool claimed;
    }

    IERC20 public immutable token; // ERC token implemntation
    uint public count; // count of the number of campaigns launched

    mapping(uint => Campaign) public campaigns; // campaignId -> Campaign
    mapping(uint => mapping(address => uint)) public amountPledged; // campaignId -> sender -> amount pledged

    constructor(address _token) {
        token = IERC20(_token); // sets address of token
    }

    /**
     *
     * @param _goal campaign target amount
     * @param _startAt start time
     * @param _endAt end time
     * @dev launch the campaign and set struct params
     */
    function launch(uint _goal, uint32 _startAt, uint32 _endAt) external {
        require(_startAt > block.timestamp, "startAt < now");
        require(_endAt > _startAt, "end at < startat");
        require(_endAt <= block.timestamp + 90 days, "endAt > max duration");

        count += 1;
        campaigns[count] = Campaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            claimed: false
        });

        emit Launch(count, msg.sender, _goal, _startAt, _endAt);
    }

    /**
     *
     * @param _id campaign id
     * @dev cancels a contract if it has not begun
     */
    function cancel(uint _id) external {
        Campaign storage campaign = campaigns[_id];

        require(msg.sender == campaign.creator, "not creator");
        require(block.timestamp < campaign.startAt, "started");
        delete campaigns[_id];
        emit Cancel(_id);
    }

    /**
     *
     * @param _id campaign id
     * @param _amount amount to pledge
     */
    function pledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];

        require(block.timestamp > campaign.startAt, "not started");
        require(block.timestamp <= campaign.endAt, "ended");

        campaign.pledged += _amount; // adds the amount
        amountPledged[_id][msg.sender] += _amount; // keep track of each depositors amount pledged
        // adds to the amount pledged to the campaign
        token.transferFrom(msg.sender, address(this), _amount); // transfers from sender to the contract

        emit Pledge(_id, msg.sender, _amount);
    }

    /**
     *
     * @param _id campaign id
     * @param _amount amount to pledge
     */
    function unPledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp <= campaign.endAt, "ended");

        campaign.pledged -= _amount;
        amountPledged[_id][msg.sender] -= _amount; // keep track of each depositors amount pledged
        // adds to the amount pledged to the campaign
        token.transfer(msg.sender, _amount);

        emit UnPledge(_id, msg.sender, _amount);
    }

    /**
     *
     * @param _id campaign id
     * @dev can only be called when the campaign goal is exceeded
     */

    function claim(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(msg.sender == campaign.creator, "not creator");
        require(block.timestamp > campaign.endAt, " not ended");
        require(campaign.pledged >= campaign.goal, "pledged < goal");
        require(!campaign.claimed, "claimed");

        campaign.claimed = true; // sets to true
        token.transfer(msg.sender, campaign.pledged); // transfers token to owner
        emit Claimed(_id, campaign.pledged);
    }

    /**
     *
     * @param _id campaign id
     * @dev can only be called when the campaign goal is not exceeded
     */
    function refund(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, " not ended");
        require(campaign.pledged < campaign.goal, "pledged > goal");

        uint bal = amountPledged[_id][msg.sender];
        amountPledged[_id][msg.sender] = 0;
        token.transfer(msg.sender, bal);
        emit Refund(_id, msg.sender, bal);
    }
}
