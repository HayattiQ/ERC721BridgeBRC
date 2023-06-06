// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import {ERC721BridgeBRCTokenMapping} from "../ERC721BridgeBRCTokenMapping.sol";
import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract MockERC721BridgeBRCA is ERC721BridgeBRCTokenMapping, ERC721A {
    constructor(address _original) ERC721("MockBTC", "MOCKBTC") {
        _registOriginalContractAddress(_original);
    }

    function mint(address to, uint256 tokenId) external virtual {
        _mint(to, tokenId);
    }

    function grantOperator(address account) external virtual {
        _grantOperator(account);
    }
}
