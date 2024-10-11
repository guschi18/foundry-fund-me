//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test} from "../lib/forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {FundFundMe} from "../script/Interactions.s.sol";
import {WithdrawFundMe} from "../script/Interactions.s.sol";

contract Interactions is Test {
    FundMe public fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_ETH_10 = 10e18;
    uint256 constant STARTING_BALANCE = 50 ether;
    uint256 constant GAS_PRICE = 1;


  function setUp() external {
    DeployFundMe deploy = new DeployFundMe();
    fundMe = deploy.run();
    vm.deal(USER, STARTING_BALANCE);
  }

  function testUserCanFundInteractions() public {
    FundFundMe fundFundMe = new FundFundMe();
    fundFundMe.fundFundMe(address(fundMe));

    WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
    withdrawFundMe.withdrawFundMe(address(fundMe));

    assert(address(fundMe).balance == 0); 
    
    
  }

  
}