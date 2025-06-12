# TRANSPARENT AUCTION SMART CONTRACT WITH COMMISSION

This project is a complete auction contract created with Solidity (version 0.8.20) that includes partial refunds and owner commission features.

---

## 1. Features

The contract implements a transparent auction system with:

- Time-limited auctions with automatic extensions
- Minimum 5% bid increment requirement
- Partial refunds for non-winning bidders (98% of their bids)
- 2% commission automatically sent to the auction owner
- Emergency withdrawal mechanism
- Real-time bid tracking and winner information

---

## 2. Contract Structure

### Key Variables
- `Bid`: Structure containing `bidder` address and `amount`
- `MyBids`: Tracks each user's `last` bid and `accumulated` total
- `bids`: Array of all bids in chronological order
- `endDate`: Auction expiration timestamp
- `initialValue`: Minimum starting bid amount
- `owner`: Contract creator address
- `finalized`: Auction completion flag

### Commission
- Fixed 2% commission on all bids
- Automatically distributed when auction ends

---

## 3. Core Functions

### `bid()`
- Submit new bids (must be ≥5% higher than previous)
- Extends auction by 10 minutes if bid occurs within last 10 minutes
- Records bid amount and updates user's bid history

### `withdrawDeposits()`
- Owner-only function to finalize auction
- Distributes:
  - 98% refunds to all non-winning bidders
  - 2% commission to owner
- Marks auction as finalized

### `partialRefund()`
- Allows bidders to reclaim excess funds above their last bid
- Available during active auction period

### `emergencyWithdraw()`
- Owner-only safety mechanism
- Recovers remaining funds after auction ends

---

## 4. View Functions

### `showWinner()`
- Returns address of current highest bidder

### `showBids()`
- Returns complete bid history array

---

## 5. Event Logging

- `AuctionStarted`: Emitted on contract creation
- `NewBid`: Recorded for each valid bid
- `AuctionEnded`: Emitted when finalized
- `Withdraw`: Logs all refund transactions
- `EmergencyWithdraw`: Records owner withdrawals

---

## 6. Business Logic

### Money Flow
1. Bidders submit increasing bids (minimum +5%)
2. When auction ends:
   - Winner pays full last bid amount
   - Non-winners receive 98% refunds
   - Owner collects 2% of all bids as commission
3. Excess funds can be reclaimed during auction

### Time Management
- Initial duration set at deployment
- Automatically extends by 10 minutes if late bids arrive
- All time calculations use blockchain timestamp

---

## 7. Usage Guide

### Deployment
1. Set constructor parameters:
   - `_duration`: Auction length in seconds
   - `_initialValue`: Minimum starting bid in wei

### Participation
1. Bidders call `bid()` with ETH value
2. Monitor status with view functions
3. Claim partial refunds when desired

### Completion
1. Owner calls `withdrawDeposits()` after endDate
2. System automatically distributes funds
3. Owner can recover remaining balance if needed

---

## 8. Technical Details

**Solidity Version:** 0.8.20  
**License:** MIT  
**Security Features:**
- Reentrancy protection
- Owner-restricted critical functions
- Automatic time extensions
- Input validation

---

## 9. Development Info

**Test Environment:**  
- Remix IDE
- Ethereum testnets

**Recommended Tools:**
- MetaMask for interaction
- Etherscan for verification
- Hardhat for local testing

---

## License

MIT License - Free to use, modify and distribute with attribution.
