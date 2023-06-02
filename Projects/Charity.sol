// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Charity {
    struct Request {
        string description;
        address needy;
        uint256 amount;
        uint256 pendingRequest;
    }

    address private supplicant;
    address public charityFounder;
    uint256 public minimumContribution;
    uint256 public deadline;
    uint256 public target;
    uint256 public raisedAmount;
    uint256 public charityMembers;
    uint256 public voteCounter;
    Request public requests;

    mapping(address => uint256) public contributors;
    mapping(address => uint256) private voter;

    constructor(
        uint256 _target,
        uint256 _deadline,
        uint256 _minimumContribution
    ) {
        target = _target;
        deadline = block.timestamp + _deadline;
        minimumContribution = _minimumContribution;
        charityFounder = msg.sender;
    }

    modifier onlyFounder() {
        require(
            charityFounder == msg.sender,
            "Charity: Only the founder can access this."
        );
        _;
    }

    function sendFund() external payable {
        if (block.timestamp > deadline) {
            revert("Charity: The deadline has passed");
        }
        require(
            msg.value >= minimumContribution,
            "Charity: Sorry! your contribution doesn't met the minimum contribution criteria."
        );

        if (contributors[msg.sender] == 0) {
            charityMembers++;
        }
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    function refund() external {
        require(
            contributors[msg.sender] > 0,
            "Charity: you are not a member of the charity."
        );
        require(
            block.timestamp > deadline && raisedAmount < target,
            "Charity: You are not eligible for the refund."
        );
        uint256 refundAmount = contributors[msg.sender];
        contributors[msg.sender] = 0;
        payable(msg.sender).transfer(refundAmount);
    }

    function raiseRequest(
        string memory _description,
        address _needy,
        uint256 _amount
    ) public {
        supplicant = msg.sender;
        require(
            contributors[supplicant] > 0 && requests.pendingRequest == 0,
            "Charity: you aren't eligible to raise request."
        );
        requests.description = _description;
        requests.needy = _needy;
        requests.amount = _amount;
        requests.pendingRequest++;
    }

    function voteForApproval(bool _vote) external {
        require(
            contributors[msg.sender] > 0 && msg.sender != supplicant,
            "Charity: you are not eligible to vote."
        );
        require(requests.pendingRequest != 0, "Charity: No requests found.");
        require(voter[msg.sender] == 0, "Charity: you have already voted.");

        if (_vote) {
            voteCounter++;
        }
        voter[msg.sender] = 1;
    }

    function approveDecision() external onlyFounder {
        require(
            voteCounter >= charityMembers / 2,
            "Charity: Request denied by more than 50% charity members."
        );

        requests.pendingRequest--;
        raisedAmount -= requests.amount;
        payable(requests.needy).transfer(requests.amount);
    }
}
