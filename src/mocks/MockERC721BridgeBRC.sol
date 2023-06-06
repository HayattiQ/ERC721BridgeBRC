// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import {ERC721BridgeBRCTokenURI} from "../ERC721BridgeBRCTokenURI.sol";
import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract MockERC721BridgeBRC is ERC721BridgeBRCTokenURI, ERC721 {
    constructor(address _original) ERC721("MockBTC", "MOCKBTC") {
        _registOriginalContractAddress(_original);
    }

    function grantOperator(address account) external virtual {
        _grantOperator(account);
    }
}
