// Get funds from users
// Set a min funding value in USD
// Withdraw fund to the sc owner's wallet

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Import Chainlink's interface for price feeds
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner(string msg);

contract FundMe {

    using PriceConverter for uint256;
    // Why multiply? using getConversionRate to get the price of ETH returns a value with 18 decimal places, so minUsd needs to be in the same format
    // Solidity works with whole numbers, since ETH is represented in its min units — Wei: 1 ETH = 1 Wei * 1e18
    // Can also use 5 * 1e18 or 5 * (10 ** 18)
    uint256 public constant MIN_USD = 5e18;
    // log senders addrs
    address[] public funders;
    // add mapping for easier funder-amount search
    mapping(address => uint256) public addressToAmountFunded;
    // Aggregator interface to facilitate deploying on different chains
    AggregatorV3Interface private s_priceFeed;
    // Set the owner of the contract
    address public immutable i_owner;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        // Allow users to send money
        // Set a min USD sent (curr val 0.001 ETH)
        require(msg.value.getConversionRate(s_priceFeed) >= MIN_USD, "Min funding amount is 5 USD");
        funders.push(msg.sender);
        // Make the sender call the func to log their addr in the funders[]
        addressToAmountFunded[msg.sender] += msg.value;
        // Add total funded to the mapping
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function withdraw() public onlyOwner {
    // Withdraw accumulated funds to the sc owner's wallet
        // Reset all the mapping to 0
        for(uint256  funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        // Reset the array
        funders = new address[](0);
        // payable(msg.sender).transfer(address(this).balance);
        // bool sendSuccess = payable(msg.sender).send(addresss(this).balance);
        // require(sendSuccess, "Send failed");
        // Withdraw funds
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
       // require() eats up too much gas; optimizing gas costs with revert(); not sure if implemented it correctly, as it's still passed a string down below and revert doesn't have a func syntax there
       // require(msg.sender == i_owner, "Sender is not owner");
       if (msg.sender != i_owner) {
        revert FundMe__NotOwner("Sender is not owner");
       }
       _;
    }

    // If somebody sends ETH to this contract/sends data without calling fund() , redirect them to fund()
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
     }
}