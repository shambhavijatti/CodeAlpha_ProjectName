// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Simple Storage Smart Contract
/// @notice CodeAlpha Blockchain Internship - Task 1
/// @dev Stores an integer that can be incremented, decremented, and read externally
contract SimpleStorage {
    // The stored value. `public` automatically creates a getter function,
    // so it satisfies the "readable from outside" requirement on its own.
    int256 public storedValue;

    // Emitted whenever the value changes, useful for tracking history off-chain.
    event ValueChanged(int256 newValue, string action);

    /// @notice Sets an initial value when the contract is deployed
    /// @param _initialValue Starting value for storedValue
    constructor(int256 _initialValue) {
        storedValue = _initialValue;
    }

    /// @notice Increases storedValue by 1
    function increment() public {
        storedValue += 1;
        emit ValueChanged(storedValue, "increment");
    }

    /// @notice Decreases storedValue by 1
    function decrement() public {
        storedValue -= 1;
        emit ValueChanged(storedValue, "decrement");
    }

    /// @notice Explicit read function (in addition to the auto-generated
    /// public getter) to make the "read from outside" requirement explicit
    function getValue() public view returns (int256) {
        return storedValue;
    }
}

