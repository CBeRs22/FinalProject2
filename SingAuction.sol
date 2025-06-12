// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title Transparent Auction with Commission and Partial Refunds
/// @author
/// @notice This contract allows running an auction with minimum incremental bids, refunds, and 2% commission to the owner.
/// @dev Uses structs for bid tracking, automatic time extensions, and secure fund handling.
contract Auction {
    struct Bid {
        address bidder;
        uint256 amount;
    }

    struct MyBids {
        uint256 last;
        uint256 accumulated; 
    }

    Bid[] public bids;
    mapping(address => MyBids) public myBids;

    uint256 public endDate;
    uint256 public initialValue;
    address public owner;
    bool public finalized;

    /// @notice Event emitted when auction starts
    event AuctionStarted(uint256 endDate);
    /// @notice Event emitted when a new valid bid is placed
    event NewBid(address indexed bidder, uint256 amount);
    /// @notice Event emitted when auction ends
    event AuctionEnded(address winner, uint256 amount);
    /// @notice Event emitted when funds are withdrawn
    event Withdraw(address indexed participant, uint256 amount);
    /// @notice Event emitted if emergency withdrawal is executed
    event EmergencyWithdraw(uint256 amount);

    /// @dev Initializes the auction with configurable duration and starting value
    /// @param _duration Duration in seconds
    /// @param _initialValue Minimum starting value (in wei)
    constructor(uint256 _duration, uint256 _initialValue) {
        require(_initialValue > 0, "Initial value must be greater than 0");
        endDate = block.timestamp + _duration;
        initialValue = _initialValue;
        owner = msg.sender;
        emit AuctionStarted(endDate);
    }

    modifier whenActive() {
        require(block.timestamp < endDate, "Auction ended");
        _;
    }

    modifier whenNotActive() {
        require(block.timestamp >= endDate, "Auction in progress");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    /// @notice Places a bid; must be 5% higher than the last one.
    function bid() external payable whenActive {
        uint256 totalBids = bids.length;
        uint256 minValue = totalBids == 0 ? initialValue : bids[totalBids - 1].amount * 105 / 100;
        require(msg.value >= minValue, "Bid too low");

        // Register bid
        myBids[msg.sender].last = msg.value;
        myBids[msg.sender].accumulated += msg.value;
        bids.push(Bid(msg.sender, msg.value));

        // Extend by 10 minutes if less than 10 minutes remaining
        if (endDate <= block.timestamp + 10 minutes) {
            endDate += 10 minutes;
        }

        emit NewBid(msg.sender, msg.value);
    }

    /// @notice Shows current winner
    /// @return Address of the highest bidder
    function showWinner() external view returns (address) {
        require(bids.length > 0, "No bids placed");
        return bids[bids.length - 1].bidder;
    }

    /// @notice Complete list of bids
    /// @return Array of bids with address and amount
    function showBids() external view returns (Bid[] memory) {
        return bids;
    }

    /// @notice Ends the auction and handles refunds and commission
    function withdrawDeposits() external whenNotActive onlyOwner {
        require(!finalized, "Already finalized");
        address winner = bids[bids.length - 1].bidder;
        uint256 commission;

        for (uint256 i = 0; i < bids.length; i++) {
            address payable participant = payable(bids[i].bidder);
            if (participant == winner) continue; // winner doesn't get refund

            uint256 value = myBids[participant].accumulated;
            uint256 refund = value * 98 / 100;
            if (refund > 0) {
                myBids[participant].accumulated = 0;
                (bool success, ) = participant.call{value: refund}("");
                require(success, "Refund failed");
                emit Withdraw(participant, refund);
            }
        }

        // Transfer 2% commission to owner
        commission = address(this).balance * 2 / 100;
        if (commission > 0) {
            (bool sent, ) = payable(owner).call{value: commission}("");
            require(sent, "Commission failed");
        }

        finalized = true;
        emit AuctionEnded(winner, bids[bids.length - 1].amount);
    }

    /// @notice Withdraws excess above last bid (while auction is active)
    function partialRefund() external whenActive {
        uint256 value = myBids[msg.sender].accumulated - myBids[msg.sender].last;
        require(value > 0, "No excess to withdraw");

        myBids[msg.sender].accumulated = myBids[msg.sender].last;
        (bool sent, ) = payable(msg.sender).call{value: value}("");
        require(sent, "Withdrawal failed");
        emit Withdraw(msg.sender, value);
    }

    /// @notice Emergency withdrawal of remaining funds (only after ending)
    function emergencyWithdraw() external onlyOwner whenNotActive {
        require(finalized, "Must finalize first");
        uint256 value = address(this).balance;
        require(value > 0, "No funds");
        (bool sent, ) = payable(owner).call{value: value}("");
        require(sent, "Emergency withdrawal failed");
        emit EmergencyWithdraw(value);
    }
}