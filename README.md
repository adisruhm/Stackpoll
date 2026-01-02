#StackPoll Smart Contract

StackPoll is a decentralized on-chain polling and voting system built on the Stacks blockchain. It enables transparent, verifiable, and tamper-proof polls that anyone can create and participate in. The contract ensures fairness by enforcing single-vote rules and providing on-chain verifiability of results.

---

Features

- **Create Polls:**  
  Users can create polls with custom titles, descriptions, and voting options.

- **Secure Voting:**  
  Participants can cast exactly one vote per poll, enforced by the contract.

- **On-Chain Transparency:**  
  All polls, votes, and results are stored on-chain for full auditability.

- **Result Retrieval:**  
  Anyone can query poll outcomes at any time.

- **Event Logging:**  
  Emitted events for poll creation and votes make off-chain indexing seamless.

---

Contract Overview

StackPoll provides core functions:

**1. Create a Poll**
Allows any user to initialize a poll by defining:
- Poll title
- Description
- Voting options

**2. Cast a Vote**
Users can vote for one of the available options.  
The system ensures:
- One vote per address
- Valid option selection

**3. View Results**
Functions allow:
- Checking total votes per option
- Fetching all poll metadata
- Verifying participants

---



