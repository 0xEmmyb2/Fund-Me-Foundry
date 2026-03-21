// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {
    AggregatorV3Interface
} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();
error MinimumNotReached();

//814618 gas
contract FundMe {
    using PriceConverter for uint256;

    address[] public funders;

    mapping(address => uint256) public addressToAmountFunded;

    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;

    address public immutable i_owner;

    AggregatorV3Interface public s_priceFeed;

    constructor(address PriceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(PriceFeed);
    }

    function fund() public payable minimum {
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function withdraw() public onlyOwner {
        //Using for loop
        //We want to get all the money funded

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            funders[funderIndex];
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        //Resetting Arrays
        funders = new address[](0);
        //Withdraw the funds

        // //transfer
        // payable(msg.sender).transfer(address(this).balance);

        // //send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        //call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    //Use of modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    modifier minimum() {
        if (msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD)
            revert MinimumNotReached();
        _;
    }

    //receive() and fallback()

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
