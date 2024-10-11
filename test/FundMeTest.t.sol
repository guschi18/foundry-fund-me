//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test} from "../lib/forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
import {console} from "../lib/forge-std/src/console.sol";

contract FundMeTest is Test {
    FundMe public fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_ETH_10 = 10e18;
    uint256 constant STARTING_BALANCE = 50 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testFundFailWitoutEnoughETH() public {
     // Berechne die minimale ETH-Menge, die weniger als 5 USD entspricht
        // Wenn 1 ETH = 2000 USD, dann 0.002 ETH = 4 USD
        uint256 ethAmount = 0.002 ether;

        // Erwartet, dass der Transaction revertiert
        vm.expectRevert();
        
        // Versuch, die fund-Funktion mit weniger als 5 USD zu funden
        fundMe.fund{value: ethAmount}();
    }

    // Without Modifier funded
    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_ETH_10}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_ETH_10);
    }

    // Section 16 Adding more coverage to the tests
    function testAddsFunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    // Section 16 Adding more coverage to the tests
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_ETH_10}();
        _;
    }
    // Section 16 Adding more coverage to the tests
    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.cheaperWithdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        // Wir berechnen auch wieviel Gas wir hier benötigen 
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);

        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        // Assert 
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance );

    }

      function testWithdrawFromMultiyplyFunders() public funded {
        // Arrange
        uint160 numbersOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numbersOfFunders; i++){
            hoax(address(i), SEND_ETH_10);
            fundMe.fund{value: SEND_ETH_10}();
        }
        // Act
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    } 

    

}
