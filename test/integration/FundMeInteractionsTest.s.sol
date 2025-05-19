// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

// Write tests in the paradigm: Arrange, Act, Assert

import {Test, console} from  "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    address USER = makeAddr("user");

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testUserCanFundInteractions() public {
        // FundFundMe fundFundMe = new FundFundMe();

        vm.prank(USER);
        vm.deal(USER, STARTING_BALANCE);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testUserCanWithdrawInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();

        vm.prank(USER);
        vm.deal(USER, STARTING_BALANCE);
        fundFundMe.fundFundMe{value: SEND_VALUE}(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();

        // Withdraw should be performed by the owner (default is address(this), so you're good)
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }

}