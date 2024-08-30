// SPDX-License-Identifier: MIT
// This line specifies the license for the smart contract, allowing others to use and modify it freely.

pragma solidity ^0.8.24;
// This declares the Solidity version the contract is written in, ensuring compatibility.

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// Imports the standard interface for ERC20 tokens, which are a common type of cryptocurrency.

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// Imports a security feature to prevent multiple calls to a function before the first call is finished.
import "./Verifier.sol"; // This will be a separate contract for zk-SNARK verification

contract AnonymousMoxieSender is ReentrancyGuard {
    // This defines our main contract, which includes protection against reentrancy attacks.

    IERC20 public moxieToken;
    // Declares a variable to interact with the Moxie token, which can't be changed after deployment.

    Verifier public verifier;
    // Declares a variable to interact with the Verifier contract, which is used for zk-SNARK verification.

    uint256 public constant MIN_DELAY = 1 hours;
    // Sets the minimum delay for transfers to 1 hour, enhancing privacy.

    uint256 public constant MAX_DELAY = 7 days;
    // Sets the maximum delay for transfers to 7 days, balancing privacy and usability.

    struct AnonymousTransfer {
        uint256 amount;
        uint256 unlockTime;
    }
    // Defines a structure to store information about each anonymous transfer.

    mapping(bytes32 => AnonymousTransfer) public transfers;
    // Creates a way to store and access transfer details using a unique identifier.

    event TransferScheduled(bytes32 indexed transferId, uint256 amount, uint256 unlockTime);
    // Defines an event to notify when a transfer is scheduled.

    event TransferCompleted(bytes32 indexed transferId, uint256 amount);
    // Defines an event to notify when a transfer is completed.

    constructor(address _moxieTokenAddress, address _verifierAddress) {
        moxieToken = IERC20(_moxieTokenAddress);
        verifier = Verifier(_verifierAddress);
    }
    // Sets up the contract by specifying which token it will work with and the verifier.

    function scheduleTransfer(bytes32 _commitment, uint256 _amount, uint256 _delay) external nonReentrant {
        // Allows users to schedule an anonymous transfer with specified details.

        require(_delay >= MIN_DELAY && _delay <= MAX_DELAY, "Delay must be between 1 hour and 7 days");
        // Ensures the delay is within the allowed range.

        require(_amount > 0, "Amount must be greater than 0");
        // Makes sure the transfer amount is valid.

        uint256 unlockTime = block.timestamp + _delay;
        // Calculates when the transfer will be available to complete.

        transfers[_commitment] = AnonymousTransfer(_amount, unlockTime);
        // Stores the transfer details using the unique identifier.

        require(moxieToken.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        // Moves the tokens from the sender to this contract, failing if unsuccessful.

        emit TransferScheduled(_commitment, _amount, unlockTime);
        // Announces that a transfer has been scheduled.
    }

    function withdraw(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[2] memory input,
        bytes32 _commitment
    ) external nonReentrant {
        require(verifier.verifyProof(a, b, c, input), "Invalid proof");
        
        AnonymousTransfer memory transfer = transfers[_commitment];
        require(transfer.unlockTime > 0, "Transfer does not exist");
        require(block.timestamp >= transfer.unlockTime, "Transfer is not yet unlocked");

        delete transfers[_commitment];

        require(moxieToken.transfer(msg.sender, transfer.amount), "Transfer failed");

        emit TransferCompleted(_commitment, transfer.amount);
    }
}