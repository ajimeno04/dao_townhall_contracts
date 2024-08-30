// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "./CiviCoin.sol";

contract TownHallDAO is Ownable {
    CiviCoin public civiCoinToken;

    struct Proposal {
        uint256 id;
        string description;
        address proposer;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 deadline;
        bool executed;
        uint256 amount; 
        address payable recipient;
        mapping(address => bool) hasVoted;
    }

    uint256 public nextProposalId;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => bool) public isUser; 

    event ProposalCreated(uint256 id, string description, address proposer);
    event Voted(uint256 proposalId, address voter, bool voteFor);
    event ProposalExecuted(uint256 id);
    event UserAdded(address indexed user, uint256 amount);

    constructor(address _civiCoinAddress) Ownable(msg.sender) {
        civiCoinToken = CiviCoin(_civiCoinAddress);
        nextProposalId = 1;
    }

    function createProposal(string calldata description, uint256 amount, address payable recipient) external {
        require(civiCoinToken.balanceOf(msg.sender) >= 1000 * 10**18, "Insufficient tokens to create a proposal");

        Proposal storage proposal = proposals[nextProposalId];
        proposal.id = nextProposalId;
        proposal.description = description;
        proposal.proposer = msg.sender;
        proposal.deadline = block.timestamp + 1 weeks; 
        proposal.amount = amount;
        proposal.recipient = recipient;

        emit ProposalCreated(nextProposalId, description, msg.sender);

        nextProposalId++;
    }

    function voteOnProposal(uint256 proposalId, uint256 voteAmount, bool voteFor) external {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp < proposal.deadline, "Voting period has ended");
        require(!proposal.hasVoted[msg.sender], "You have already voted on this proposal");
        require(civiCoinToken.balanceOf(msg.sender) >= voteAmount, "Insufficient tokens to vote");

        uint256 quadraticVote = voteAmount * voteAmount;

        if (voteFor) {
            proposal.votesFor += quadraticVote;
        } else {
            proposal.votesAgainst += quadraticVote;
        }

        proposal.hasVoted[msg.sender] = true;

        emit Voted(proposalId, msg.sender, voteFor);
    }

    function executeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.deadline, "Voting period has not ended");
        require(!proposal.executed, "Proposal has already been executed");

        uint256 totalVotes = proposal.votesFor + proposal.votesAgainst;
        uint256 quorum = civiCoinToken.totalSupply() / 4; 
        require(totalVotes >= quorum, "Quorum not reached");

        if (proposal.votesFor > proposal.votesAgainst) {
           
            proposal.executed = true;
            emit ProposalExecuted(proposalId);

            
            proposal.recipient.transfer(proposal.amount);
        } else {
            proposal.executed = true;
        }
    }

    // Function to deposit funds into the DAO
    receive() external payable {}

    function withdrawFunds(uint256 amount) external onlyOwner {
        payable(owner()).transfer(amount);
    }

    function addUser(address user, uint256 amount) external onlyOwner {
        require(!isUser[user], "User already exists");

        civiCoinToken.mint(user, amount);

        isUser[user] = true;

        emit UserAdded(user, amount);
    }
}
