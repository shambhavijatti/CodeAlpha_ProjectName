// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Polling System Smart Contract
/// @notice CodeAlpha Blockchain Internship - Task 3
/// @dev Lets users create time-bound polls, vote once per address, and read the winner
contract PollingSystem {
    struct Poll {
        string title;
        string[] options;
        uint256 endTime;
        address creator;
        bool exists;
        // optionIndex => vote count
        mapping(uint256 => uint256) voteCounts;
        // voter address => has voted on this poll
        mapping(address => bool) hasVoted;
    }

    // pollId => Poll
    mapping(uint256 => Poll) private polls;
    uint256 public pollCount;

    event PollCreated(uint256 indexed pollId, string title, uint256 endTime, uint256 optionCount);
    event Voted(uint256 indexed pollId, address indexed voter, uint256 optionIndex);

    modifier pollExists(uint256 _pollId) {
        require(polls[_pollId].exists, "Poll does not exist");
        _;
    }

    /// @notice Creates a new poll
    /// @param _title Poll question/title
    /// @param _options List of voting options (at least 2)
    /// @param _durationInSeconds How long (from now) the poll stays open
    function createPoll(
        string calldata _title,
        string[] calldata _options,
        uint256 _durationInSeconds
    ) external returns (uint256 pollId) {
        require(_options.length >= 2, "Need at least 2 options");
        require(_durationInSeconds > 0, "Duration must be > 0");

        pollId = pollCount++;
        Poll storage p = polls[pollId];
        p.title = _title;
        p.endTime = block.timestamp + _durationInSeconds;
        p.creator = msg.sender;
        p.exists = true;

        for (uint256 i = 0; i < _options.length; i++) {
            p.options.push(_options[i]);
        }

        emit PollCreated(pollId, _title, p.endTime, _options.length);
    }

    /// @notice Cast a vote on an active poll. Each address may vote once per poll.
    /// @param _pollId ID of the poll
    /// @param _optionIndex Index into the poll's options array
    function vote(uint256 _pollId, uint256 _optionIndex) external pollExists(_pollId) {
        Poll storage p = polls[_pollId];
        require(block.timestamp < p.endTime, "Voting has ended");
        require(!p.hasVoted[msg.sender], "Address has already voted");
        require(_optionIndex < p.options.length, "Invalid option index");

        p.hasVoted[msg.sender] = true;
        p.voteCounts[_optionIndex] += 1;

        emit Voted(_pollId, msg.sender, _optionIndex);
    }

    /// @notice Returns basic poll info
    function getPoll(uint256 _pollId)
        external
        view
        pollExists(_pollId)
        returns (string memory title, string[] memory options, uint256 endTime, address creator)
    {
        Poll storage p = polls[_pollId];
        return (p.title, p.options, p.endTime, p.creator);
    }

    /// @notice Returns the vote count for a given option in a poll
    function getVoteCount(uint256 _pollId, uint256 _optionIndex)
        external
        view
        pollExists(_pollId)
        returns (uint256)
    {
        require(_optionIndex < polls[_pollId].options.length, "Invalid option index");
        return polls[_pollId].voteCounts[_optionIndex];
    }

    /// @notice Whether a given address has already voted in a poll
    function hasAddressVoted(uint256 _pollId, address _voter)
        external
        view
        pollExists(_pollId)
        returns (bool)
    {
        return polls[_pollId].hasVoted[_voter];
    }

    /// @notice Determines and returns the winning option after the poll has ended
    /// @return winningOption The text of the winning option
    /// @return winningIndex Index of the winning option
    /// @return winningVotes Vote count the winner received
    function getWinner(uint256 _pollId)
        external
        view
        pollExists(_pollId)
        returns (string memory winningOption, uint256 winningIndex, uint256 winningVotes)
    {
        Poll storage p = polls[_pollId];
        require(block.timestamp >= p.endTime, "Poll has not ended yet");

        uint256 highestVotes = 0;
        uint256 winnerIndex = 0;

        for (uint256 i = 0; i < p.options.length; i++) {
            uint256 votes = p.voteCounts[i];
            if (votes > highestVotes) {
                highestVotes = votes;
                winnerIndex = i;
            }
        }

        return (p.options[winnerIndex], winnerIndex, highestVotes);
    }
}

/*
============================================================
 HOW TO COMPILE, DEPLOY & TEST ON REMIX IDE (remix.ethereum.org)
============================================================
1. Paste as Task3_PollingSystem.sol, compile with Solidity 0.8.20+.
2. Deploy on "Remix VM (Cancun)" (no constructor args).
3. Testing:
   - Call "createPoll" with:
       _title: "Favorite Language"
       _options: ["Solidity","Rust","Python"]
       _durationInSeconds: 120   (2 minutes, for quick testing)
   - Note the returned pollId (usually 0 for the first poll) via the
     "PollCreated" event log or by calling "pollCount".
   - Switch between different test accounts (top-left dropdown) and call
     "vote" with (pollId, optionIndex) for each account, e.g. vote(0, 0).
   - Try voting twice from the same account -> should revert with
     "Address has already voted".
   - Call "getVoteCount(0, 0)" etc. to see live tallies.
   - Since Remix VM lets you simulate time, use "getPoll" to see endTime,
     then either wait out the real duration or redeploy with a very short
     _durationInSeconds (e.g. 5 seconds) and wait 5+ seconds before calling
     "getWinner". Calling getWinner before endTime reverts with
     "Poll has not ended yet", proving the time-lock works.
============================================================
*/
