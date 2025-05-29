// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Project {
    // Structure to represent a candidate
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }
    
    // Structure to represent a voter
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedCandidateId;
    }
    
    // State variables
    address public owner;
    mapping(uint => Candidate) public candidates;
    mapping(address => Voter) public voters;
    uint public candidatesCount;
    bool public votingActive;
    
    // Events
    event CandidateAdded(uint candidateId, string name);
    event VoterRegistered(address voter);
    event VoteCast(address voter, uint candidateId);
    event VotingStatusChanged(bool status);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier onlyRegisteredVoter() {
        require(voters[msg.sender].isRegistered, "You must be registered to vote");
        _;
    }
    
    modifier votingIsActive() {
        require(votingActive, "Voting is not currently active");
        _;
    }
    
    // Constructor
    constructor() {
        owner = msg.sender;
        votingActive = false;
    }
    
    // Core Function 1: Add candidates (only owner)
    function addCandidate(string memory _name) public onlyOwner {
        require(bytes(_name).length > 0, "Candidate name cannot be empty");
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
        emit CandidateAdded(candidatesCount, _name);
    }
    
    // Core Function 2: Register voters (only owner)
    function registerVoter(address _voter) public onlyOwner {
        require(!voters[_voter].isRegistered, "Voter is already registered");
        voters[_voter] = Voter(true, false, 0);
        emit VoterRegistered(_voter);
    }
    
    // Core Function 3: Cast vote (registered voters only)
    function vote(uint _candidateId) public onlyRegisteredVoter votingIsActive {
        require(!voters[msg.sender].hasVoted, "You have already voted");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID");
        
        // Record the vote
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
        
        // Update candidate vote count
        candidates[_candidateId].voteCount++;
        
        emit VoteCast(msg.sender, _candidateId);
    }
    
    // Additional utility functions
    function toggleVoting() public onlyOwner {
        votingActive = !votingActive;
        emit VotingStatusChanged(votingActive);
    }
    
    function getCandidate(uint _candidateId) public view returns (uint, string memory, uint) {
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID");
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }
    
    function getVoterInfo(address _voter) public view returns (bool, bool, uint) {
        Voter memory voter = voters[_voter];
        return (voter.isRegistered, voter.hasVoted, voter.votedCandidateId);
    }
    
    function getWinner() public view returns (uint, string memory, uint) {
        require(candidatesCount > 0, "No candidates available");
        
        uint winningVoteCount = 0;
        uint winningCandidateId = 0;
        
        for (uint i = 1; i <= candidatesCount; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningCandidateId = i;
            }
        }
        
        return (winningCandidateId, candidates[winningCandidateId].name, winningVoteCount);
    }
}
