// SPDX-License-Identifier: MIT
// Handler is going to narrow down the way we call function

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizeStableCoin.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";
import {MockAggregator} from "../mocks/MockV3Aggregator.sol";

contract Handler is Test {
    DSCEngine dsce;
    DecentralizedStableCoin dsc;

    ERC20Mock weth;
    ERC20Mock wbtc;

    // Ghost Variables
    uint256 public timeMintIsCalled;
    address[] public usersWithCollateralDeposited;
    MockV3Aggregator public ethUsdPriceFeed;

    uint256 MAX_DEPOSIT_SIZE = type(uint96).max;

    constructor(DSCEngine _dscEngine, DecentralizedStableCoin _dsc) {
        dsce = _dscEngine;
        dsc = _dsc;

        address[] memory collateralTokens = dsce.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);

        ethUsdPriceFeed = dsce.getCollateralTokenPriceFeed(address(weth));

        // ethUsdPriceFeed = MockV3Aggregator(dscEngine.getCollateralTokenPriceFeed(address(weth)));
        // btcUsdPriceFeed = MockV3Aggregator(dscEngine.getCollateralTokenPriceFeed(address(wbtc)));
    }

    // function mintAndDepositCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
    //     amountCollateral = bound(amountCollateral, 1, MAX_DEPOSIT_SIZE);
    //     ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
    //     collateral.mint(msg.sender, amountCollateral);
    //     collateral.approve(address(dsce), amountCollateral);
    //     dsce.depositCollateral(address(collateral), amountCollateral);
    // }
    // function mintDsc(uint256 amount, uint256 addressSeed) public {
    //     if (usersWithCollateralDeposited.length == 0) {
    //         return;
    //     }
    //     address sender = usersWithCollateralDeposited[addressSeed % usersWithCollateralDeposited.length];
    //     // amount = bound(amount, 0, MAX_DEPOSIT_SIZE);
    //     (uint256 totalDscMinted, uint256 collateralValueInUsd) = dsce.getAccountInformation(sender);
    //     uint256 maxDscToMint = (collateralValueInUsd / 2) - totalDscMinted;
    //     if (int256(maxDscToMint) < 0) {
    //         return;
    //     }
    //     amount = bound(amount, 0, maxDscToMint);
    //     if (maxDscToMint == 0) {
    //         return;
    //     }
    //     vm.startPrank(sender);
    //     dsce.mintDSC(amount);
    //     vm.stopPrank();
    //     timeMintIsCalled++;
    // }
    // redeem collateral <-

    function depositCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        amountCollateral = bound(amountCollateral, 0, MAX_DEPOSIT_SIZE);

        vm.startPrank(msg.sender);
        collateral.mint(msg.sender, amountCollateral);
        collateral.approve(address(dsce), amountCollateral);
        dsce.depositCollateral(address(collateral), amountCollateral);
        vm.stopPrank();

        //
        usersWithCollateralDeposited.push(msg.sender);
    }

    // function redeemCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
    //     ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
    //     uint256 maxCollateralToRedeem = dsce.getCollateralBalanceOfUser(address(collateral), msg.sender);
    //     // There is a bug, where a user can redeem more than they have.
    //     amountCollateral = bound(amountCollateral, 0, maxCollateralToRedeem);
    //     if (amountCollateral == 0) {
    //         return;
    //     }
    //     dsce.redeemCollateral(address(collateral), amountCollateral);
    // }

    // Hey!!! This breaks our invariant test suite!!!
    // function updateCollateralPrice(uint96 newPrice) public {
    //     int256 newPriceInt = int256(uint256(newPrice));
    //     ethUsdPriceFeed.updateAnswer(newPriceInt);

    // }

    // Helper Functions
    function _getCollateralFromSeed(uint256 collateralSeed) private view returns (ERC20Mock) {
        if (collateralSeed % 2 == 0) {
            return weth;
        }
        return wbtc;
    }

    // function invariant_gettersShouldNotRevert() public {
    //     dsce.getLiquidationBonus();
    //     dsce.getPrecision();
    // }
}
