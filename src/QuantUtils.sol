// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IQToken} from "quant-protocol/interfaces/IQToken.sol";
import {ICollateralToken} from "quant-protocol/interfaces/ICollateralToken.sol";

contract QuantUtils {
    struct QTokenInfo {
        address underlyingAsset;
        address strikeAsset;
        address oracle;
        uint256 strikePrice;
        uint256 expiryTime;
        bool isCall;
    }

    struct CollateralTokenDetails {
        address underlyingAsset;
        address strikeAsset;
        address oracle;
        uint256 shortStrikePrice;
        uint256 longStrikePrice;
        uint256 expiryTime;
        bool isCall;
    }

    function getQTokenInfo(IQToken qToken)
        public
        pure
        returns (QTokenInfo memory qTokenInfo)
    {
        qTokenInfo = QTokenInfo(
            qToken.underlyingAsset(),
            qToken.strikeAsset(),
            qToken.oracle(),
            qToken.strikePrice(),
            qToken.expiryTime(),
            qToken.isCall()
        );
    }

    function getCollateralTokenDetails(
        address collateralToken,
        uint256 cTokenId
    )
        external
        view
        returns (CollateralTokenDetails memory collateralTokenDetails)
    {
        (address qTokenAddress, address qTokenAsCollateral) =
            ICollateralToken(collateralToken).idToInfo(cTokenId);

        QTokenInfo memory shortDetails = getQTokenInfo(IQToken(qTokenAddress));

        collateralTokenDetails.underlyingAsset = shortDetails.underlyingAsset;
        collateralTokenDetails.strikeAsset = shortDetails.strikeAsset;
        collateralTokenDetails.oracle = shortDetails.oracle;
        collateralTokenDetails.shortStrikePrice = shortDetails.strikePrice;
        collateralTokenDetails.expiryTime = shortDetails.expiryTime;
        collateralTokenDetails.isCall = shortDetails.isCall;
        collateralTokenDetails.longStrikePrice = 0;
        if (qTokenAsCollateral != address(0)) {
            // the given id is for a CollateralToken representing a spread
            collateralTokenDetails.longStrikePrice =
                IQToken(qTokenAsCollateral).strikePrice();
        }
    }
}