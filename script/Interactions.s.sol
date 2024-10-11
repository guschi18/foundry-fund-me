// SPDX-License-Identifier: MIT

// Fund 
// Withdraw

pragma solidity ^0.8.24;

import { Script, console } from "../lib/forge-std/src/Script.sol";
import { DevOpsTools } from "../lib/foundry-devops/src/DevOpsTools.sol";
import { FundMe } from "../src/FundMe.sol";

contract FundFundMe is Script {
  uint256 constant SEND_VALUE = 0.01 ether;

  function fundFundMe(address mostRecentyDeployed) public {
    vm.startBroadcast();
    FundMe(payable(mostRecentyDeployed)).fund{value: SEND_VALUE}();
    vm.stopBroadcast();
    console.log("Funded the contract");
    
  }

  function run() external {
    address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
    vm.startBroadcast();
    fundFundMe(mostRecentlyDeployed);
    vm.stopBroadcast();
  }

  }

contract WithdrawFundMe is Script {
function withdrawFundMe(address mostRecentyDeployed) public {
    vm.startBroadcast();
    FundMe(payable(mostRecentyDeployed)).cheaperWithdraw();
    vm.stopBroadcast();
    console.log("Funded the contract");

  }

  
}