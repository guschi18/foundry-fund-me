// SPDX-License-Identifier: MIT

// 1. Deploy mock when we are on a local anvil chain
// 2. Keep track of contract address across different chains
// 3. We can do this with any chain we want, you only have to add e new function with the correct address of the new network 

pragma solidity ^0.8.24;

import { Script } from "../lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
  // If we are on a local anvil, we deploy mocks
  // Otherwise, grab the existing address from live network 
  NetworkConfig public activenetworkConfig;

  uint8 public constant DECIMALS = 8;
  int256 public constant INITIAL_PRICE = 2000e8;

  struct NetworkConfig {
    address priceFeed; // ETH/USD price feed address
  }

  constructor(){
    if (block.chainid == 11155111) {
      activenetworkConfig = getSepoliaEthConfig();
    } else if (block.chainid == 1) { 
      activenetworkConfig = getMainEthConfig();
    } else {
      activenetworkConfig = getAnvilEthConfig();
    }
  }

  function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
    // price feed address
    NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});

    return sepoliaConfig;
  }

  function getMainEthConfig() public pure returns (NetworkConfig memory){
    // price feed address
    NetworkConfig memory mainEthConfig = NetworkConfig({priceFeed: 0x72AFAECF99C9d9C8215fF44C77B94B99C28741e8});

    return mainEthConfig;
  }

  function getAnvilEthConfig() public returns (NetworkConfig memory){
    if (activenetworkConfig.priceFeed != address(0)){
      return activenetworkConfig;
    }
    // price feed address

    // 1. Deploy the mocks
    // 2. Return the mock address

    vm.startBroadcast();
    MockV3Aggregator mockPricefeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
    vm.stopBroadcast();

    NetworkConfig memory anvilconfig = NetworkConfig({
      priceFeed: address(mockPricefeed)
    });
    return anvilconfig;
  }
}