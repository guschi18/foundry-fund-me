// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import { Script } from "../lib/forge-std/src/Script.sol";
import { FundMe } from "../src/FundMe.sol";
import { HelperConfig } from "./HelperConfig.s.sol";

contract DeployFundMe is Script{
    function run() external returns (FundMe) {
      // before a txs is on the chain
      HelperConfig helperConfig = new HelperConfig();
      address ethUsdPriceFeed = helperConfig.activenetworkConfig();
      // txs is on the chain 
      vm.startBroadcast();
      // Mock
     FundMe fundMe = new FundMe(ethUsdPriceFeed);

      vm.stopBroadcast();
      return fundMe;

    
    }
}