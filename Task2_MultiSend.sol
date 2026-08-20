// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Multi-Send Smart Contract
/// @notice CodeAlpha Blockchain Internship - Task 2
/// @dev Accepts an array of addresses and splits the sent Ether equally among them
contract MultiSend {
    event MultiSendExecuted(address indexed sender, uint256 totalAmount, uint256 recipientCount);
    event TransferFailed(address indexed recipient, uint256 amount);

    /// @notice Sends an equal share of msg.value to every address in `recipients`
    /// @param recipients Array of Ethereum addresses to receive Ether
    function multiSend(address payable[] calldata recipients) external payable {
        uint256 count = recipients.length;
        require(count > 0, "No recipients provided");
        require(msg.value > 0, "Must send some Ether");

        // Split evenly. Solidity integer division truncates, so any tiny
        // remainder (dust) stays in the contract rather than being lost.
        uint256 share = msg.value / count;
        require(share > 0, "Amount too small to split among recipients");

        for (uint256 i = 0; i < count; i++) {
            address payable recipient = recipients[i];
            require(recipient != address(0), "Invalid recipient address");

            // Using call instead of transfer/send for safer, gas-flexible transfers
            (bool success, ) = recipient.call{value: share}("");
            if (!success) {
                // We don't revert the whole batch on one failure; we simply
                // record it so the sender can investigate. Any funds not
                // sent successfully remain in this contract's balance.
                emit TransferFailed(recipient, share);
            }
        }

        emit MultiSendExecuted(msg.sender, msg.value, count);
    }

    /// @notice Lets the contract owner-less design still allow recovery of
    /// any leftover "dust" Ether (from division remainders or failed sends)
    /// @dev For a production contract you'd typically restrict this to an
    /// owner; kept open here for simplicity/testing purposes.
    function withdrawDust(address payable to, uint256 amount) external {
        require(amount <= address(this).balance, "Insufficient contract balance");
        (bool success, ) = to.call{value: amount}("");
        require(success, "Withdrawal failed");
    }

    /// @notice View the contract's current Ether balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Allows the contract to receive Ether directly (e.g. leftover dust)
    receive() external payable {}
}
