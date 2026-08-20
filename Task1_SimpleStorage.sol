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

/*
============================================================
 HOW TO COMPILE, DEPLOY & TEST ON REMIX IDE (remix.ethereum.org)
============================================================
1. Go to https://remix.ethereum.org
2. Create a new file: Task1_SimpleStorage.sol and paste this code.
3. Open the "Solidity Compiler" tab (left sidebar), select compiler
   version 0.8.20 (or any 0.8.x), click "Compile Task1_SimpleStorage.sol".
4. Open the "Deploy & Run Transactions" tab.
   - Environment: "Remix VM (Cancun)" is fine for testing.
   - In the constructor field next to "Deploy", enter an initial value,
     e.g. 0, then click "Deploy".
5. Testing:
   - Under "Deployed Contracts", expand the contract.
   - Click "storedValue" (blue button) -> should show your initial value.
   - Click "increment" (orange button) a few times, then click
     "storedValue" again -> value should have gone up by 1 each time.
   - Click "decrement" a few times -> value should go down by 1 each time.
   - Click "getValue" -> confirms the same value is readable via the
     explicit read function too.
============================================================
*/
