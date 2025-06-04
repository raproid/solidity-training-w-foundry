// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "script/HelperConfigRaffle.s.sol";
import "forge-std/console.sol";
Фввimport {CreateSubscription, FundSubscription, AddConsumer} from "script/Interactions.s.sol";

contract DeployRaffle is Script {

    function run() public {
        (Raffle raffle, ) = deployRaffleContract();
        console.log("Raffle deployed to:", address(raffle));
    }

    function deployRaffleContract() public returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        // Get network-specific config
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        // Check if the config is valid
        if (config.subscriptionId == 0) {
            // Create a new subscription if it doesn't exist
            CreateSubscription createSubscription = new CreateSubscription();
            (config.subscriptionId, config.vrfCoordinator) = createSubscription.createSubscription(config.vrfCoordinator, config.account);
            // Fund the subscription
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(config.vrfCoordinator, config.subscriptionId, config.link, config.account);
        }
        // Deploy the Raffle contract with the configuration
        vm.startBroadcast(config.account);
        Raffle raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.vrfCoordinator,
            config.gasLane,
            config.subscriptionId,
            config.callbackGasLimit
        );
        vm.stopBroadcast();

        // Add the Raffle contract as a consumer to the VRF subscription
        AddConsumer addConsumer = new AddConsumer();
        // Don't need to broadcast here — broadcasting in addConsumer
        addConsumer.addConsumer(address(raffle), config.vrfCoordinator, config.subscriptionId, config.account);

        return (raffle, helperConfig);
    }
}