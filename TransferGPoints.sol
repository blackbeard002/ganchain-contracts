// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

error InvalidOwnerAddress();
error InvalidFundsHandlerAddress();
error InvalidAmount();
error InvalidSS58Address();
error TransferFailed();

contract TransferGPoints is Ownable, ReentrancyGuard, Pausable {

    address public fundsHandler;

    event GPointsReceived(address indexed _sender, string ss58Address, uint _amount, uint timestamp);

    constructor(address initialOwner, address _fundsHandler) Ownable(initialOwner) {
        if (initialOwner == address(0)) revert InvalidOwnerAddress();
        if (_fundsHandler == address(0)) revert InvalidFundsHandlerAddress();
        fundsHandler = _fundsHandler;
    }

    /// @notice Transfer native tokens to the funds handler and emit an event
    /// @param _ss58Address The SS58 address associated with the transfer
    function transfer(string calldata _ss58Address) external payable nonReentrant {
        if (msg.value == 0) revert InvalidAmount();
        if (bytes(_ss58Address).length != 48) revert InvalidSS58Address();

        (bool success, ) = payable(fundsHandler).call{value: msg.value}("");
        if (!success) revert TransferFailed();

        emit GPointsReceived(msg.sender, _ss58Address, msg.value, block.timestamp);
    }

    /// @notice Update the funds handler address
    /// @param _fundsHandler The new address to receive funds
    function setFundsHandler(address _fundsHandler) external onlyOwner {
        if (_fundsHandler == address(0)) revert InvalidFundsHandlerAddress();
        fundsHandler = _fundsHandler;
    }

    /// @notice Pause the contract
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Unpause the contract
    function unpause() external onlyOwner {
        _unpause();
    }
}