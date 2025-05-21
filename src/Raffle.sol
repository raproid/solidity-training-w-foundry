// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
* @title A sample Raffle contract
* @author Ole Sorensen
* @notice This contract creates a sample raffle
* @dev Implements Chainlink VRF v2.5
 */
contract Raffle is VRFConsumerBaseV2Plus {
    /* Errors */
    error Raffle__SendMoreToEnterRaffle();
    error Raffle__NotEnoughTimePassed();
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();

    /* Type Declarations */
    enum RaffleState {
        OPEN, // 0
        CALCULATING // 1
    }

    /* State Variables */
    uint256 private immutable i_enteranceFee;
    address payable[] private s_players;
    // @dev Duration of the lottery in seconds
    uint256 private immutable i_interval;
    uint256 private immutable i_subscriptionId;
    // gasLane
    bytes32 private immutable i_keyHash;
    uint256 private s_lastTimeStamp;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private immutable i_callbackGasLimit;
    uint32 private constant NUM_WORDS = 1;
    address private s_recentWinner;
    RaffleState private s_raffleState;
    /* Events */
    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);

    constructor(uint256 entranceFee, uint256 interval, address vrfCoordinator, bytes32 gasLane, uint256 subscriptionId, uint32 callbackGasLimit)
    VRFConsumerBaseV2Plus(vrfCoordinator) {
        // @dev Entrance fee in wei
        i_enteranceFee = entranceFee;
        // @dev Duration of the lottery in seconds
        i_interval = interval;
        // @dev Timestamp of the last lottery
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;

        s_lastTimeStamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() external payable{
       if(msg.value < i_enteranceFee) {
           revert Raffle__SendMoreToEnterRaffle();
       }
        if(s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }
        s_players.push(payable(msg.sender));
        // Emit event for easier migration and frontend indexing
        emit RaffleEntered(msg.sender);
    }

    // 1. Get a random number
    // 2. Use this random number to pick a winner
    // 3. Auto-called func
    function pickWinner() external {
         // Check to see if enough time has passed
       if((block.timestamp - s_lastTimeStamp) < i_interval) {
        revert Raffle__NotEnoughTimePassed();
        }
        s_raffleState = RaffleState.CALCULATING;
        // Get random number via Chainlink's VRF v2.5
        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
            keyHash: i_keyHash,
            subId: i_subscriptionId,
            requestConfirmations: REQUEST_CONFIRMATIONS,
            callbackGasLimit: i_callbackGasLimit,
            numWords: NUM_WORDS,
            extraArgs: VRFV2PlusClient._argsToBytes(
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
            )
        });
      uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
    }

    // CEI: Checks, Effects, Interactions pattern
    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        // Checks

        // Effects
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        emit WinnePicker(s_recentWinner);

        // Interactions with external contracts
        // Transfer the entire balance of the contract to the winner
    (bool success,) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
}

    /* Getters */
    function getEntranceFee() external view returns (uint256) {
        return i_enteranceFee;
    }
}