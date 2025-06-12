# AUCTION SMART CONTRACT – FINAL PROJECT (Module 2)

This project is part of the final work for Module 2 of the EthKipu Blockchain Builder program. It is a simple but complete auction contract created with Solidity (version 0.8.20) and deployed on the Sepolia testnet.

---

## 1. What it does

The contract allows people to participate in a decentralized auction using ETH. It includes some useful features:

- You can only bid if the auction is active.
- Each new bid must be at least 5% higher than the last one.
- If someone bids close to the end, the auction time is extended by 10 minutes.
- Users who don’t win get 98% of their ETH back automatically.
- The owner gets a 2% commission from the winner’s bid.

---

## 2. Main Variables and Structures

- `Bid`: a structure with bidder address and amount.
- `bids`: list of all valid bids.
- `myBids`: tracks the total and last bid per user.
- `endDate`: when the auction ends.
- `owner`: the person who created the auction.
- `commissionRate`: fixed at 2%.

---

## 3. Functions

### Constructor

- Sets who the owner is.
- Defines how long the auction will last.

### `bid()`

- Called when someone wants to make an offer.
- The first bid must be higher than the initial value.
- Other bids must be at least 5% more than the current one.
- Extends time if needed.
- Records the bid.

### `retDeposit()`

- Ends the auction (only owner).
- Transfers 98% refund to other users.
- Sends 2% commission to owner.
- Marks the auction as ended.

### `partialRefund()`

- Lets users take back extra funds if they overbid more than once.

### `emergencyWithdraw()`

- Only for the owner.
- Can take out all ETH after the auction ends (as a backup option).

---

## 4. Events

- `NewOffer`: a new valid bid was made.
- `AuctionEnded`: the auction finished.
- `PartialRefund`: someone claimed back excess ETH.
- `EmergencyWithdraw`: owner took out remaining funds.

---

## 5. 👀 Extra Features

- `showWinner()`: shows the highest bid and who made it.
- `showBids()`: shows all bids made.
- `getTimeRemaining()`: tells how much time is left.
- `totalBidOf(address)`: shows how much a user has offered.

---

## 6. How money moves

- Winner pays → 2% goes to owner.
- 98% of non-winning bids are refunded.
- Users can get back their extra ETH before auction ends.

---

## 7. How to use it

1. Deploy the contract with a duration.
2. Bidders call `bid()` and send ETH.
3. Once time is up, owner calls `retDeposit()`.
4. Refunds and commission are sent automatically.
5. Users can also call `partialRefund()` if needed.

---

## 8. Deployment Info

- **Testnet**: Sepolia
- **Contract Address**: `0x790FD2ECf5eDAb4FCb651A0dCa41f2E4dc673ccC`
- **Tools used**: Remix + MetaMask

---

## 9. Made by

Created by Cabral Leonel, as a final project for Module 2 in the EthKipu program.

---

## License

MIT – Feel free to use or improve it.
