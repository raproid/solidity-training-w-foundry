// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "./HelperConfigRaffle.s.sol";
import "forge-std/console.sol";

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