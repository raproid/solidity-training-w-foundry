// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "script/HelperConfigRaffle.s.sol";
import "forge-std/console.sol";
import {CreateSubscription} from "script/Interactions.s.sol";

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
            CreateSubscription createSubscription = new CreateSubscription();
            (config.subscriptionId, config.vrfCoordinator) = createSubscription.createSubscription(config.vrfCoordinator);
        }
        vm.startBroadcast();
        Raffle raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.vrfCoordinator,
            config.gasLane,
            config.subscriptionId,
            config.callbackGasLimit
        );
        vm.stopBroadcast();
        return (raffle, helperConfig);
    }
}