// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Personal Portfolio (Crypto Locking) Smart Contract
/// @notice CodeAlpha Blockchain Internship - Task 4
/// @dev Users deposit Ether with a lock-in period and can only withdraw after it passes
contract CryptoLock {
    struct Deposit {
        uint256 amount;
        uint256 unlockTime;
    }

    // user address => their deposit info
    mapping(address => Deposit) public deposits;

    event Deposited(address indexed user, uint256 amount, uint256 unlockTime);
    event Withdrawn(address indexed user, uint256 amount);

    /// @notice Deposit Ether and lock it until `_lockDurationInSeconds` from now
    /// @dev If the user already has an active, unwithdrawn deposit, this adds
    /// to it and extends the unlock time to the new (later) deadline.
    /// @param _lockDurationInSeconds How long the funds should stay locked
    function deposit(uint256 _lockDurationInSeconds) external payable {
        require(msg.value > 0, "Must deposit some Ether");
        require(_lockDurationInSeconds > 0, "Lock duration must be > 0");

        Deposit storage d = deposits[msg.sender];
        uint256 newUnlockTime = block.timestamp + _lockDurationInSeconds;

        d.amount += msg.value;
        // Keep whichever unlock time is later, so a new deposit can't be
        // used to sneak an earlier withdrawal on previously locked funds.
        if (newUnlockTime > d.unlockTime) {
            d.unlockTime = newUnlockTime;
        }


        emit Deposited(msg.sender, msg.value, d.unlockTime);
    }

    /// @notice Withdraw the caller's full deposit, only allowed after unlockTime
    function withdraw() external {
        Deposit storage d = deposits[msg.sender];
        require(d.amount > 0, "No funds to withdraw");
        require(block.timestamp >= d.unlockTime, "Funds are still locked");

        uint256 amountToSend = d.amount;
        d.amount = 0;
        d.unlockTime = 0;

        (bool success, ) = payable(msg.sender).call{value: amountToSend}("");
        require(success, "Withdrawal transfer failed");

        emit Withdrawn(msg.sender, amountToSend);
    }

    /// @notice Check how much time (in seconds) remains until a user's funds unlock
    /// @return secondsRemaining 0 if already unlocked or no deposit exists
    function timeUntilUnlock(address _user) external view returns (uint256 secondsRemaining) {
        Deposit memory d = deposits[_user];
        if (d.amount == 0 || block.timestamp >= d.unlockTime) {
            return 0;
        }
        return d.unlockTime - block.timestamp;
    }

    /// @notice Convenience view of a user's locked amount and unlock timestamp
    function getDeposit(address _user) external view returns (uint256 amount, uint256 unlockTime) {
        Deposit memory d = deposits[_user];
        return (d.amount, d.unlockTime);
    }
}

