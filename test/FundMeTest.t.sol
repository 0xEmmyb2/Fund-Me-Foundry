//SPDX-License-Identifer: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test{
    FundMe fundMe;

    function setUp() external {
        //us -> FundMeTest -> FundMe
        fundMe = new FundMe();
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        console.log("Owner: ", fundMe.i_owner());
        console.log("Msg Sender: ", msg.sender);
        assertEq(fundMe.i_owner(), address(this));
    }
}

