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
    address[] private s_funders;
    // add mapping for easier funder-amount search
    mapping(address => uint256) private s_addressToAmountFunded;
    // Aggregator interface to facilitate deploying on different chains
    AggregatorV3Interface private s_priceFeed;
    // Set the owner of the contract
    address private immutable i_owner;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        // Allow users to send money
        // Set a min USD sent (curr val 0.001 ETH)
        require(msg.value.getConversionRate(s_priceFeed) >= MIN_USD, "Min funding amount is 5 USD");
        s_funders.push(msg.sender);
        // Make the sender call the func to log their addr in the funders[]
        s_addressToAmountFunded[msg.sender] += msg.value;
        // Add total funded to the mapping
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    // Let's read from memory, not storage, using x2 less gas
    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for(uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");

    }

    function withdraw() public onlyOwner {
    // Withdraw accumulated funds to the sc owner's wallet
        // Reset all the mapping to 0
        for(uint256  funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // Reset the array
        s_funders = new address[](0);
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
        revert FundMe__NotOwner("Caller is not owner");
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

    /**
    View, pure funcs (Getters)
    */
    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}