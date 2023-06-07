// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import {ERC721ABridgeBRC} from "../extensions/ERC721ABridgeBRC.sol";

contract SimpleERC721BridgeBRCA is ERC721ABridgeBRC {
    constructor(
        address _original
    ) ERC721ABridgeBRC("MockBTC", "MOCKBTC", _original) {}

    function mint(address to, uint256 amount) external virtual {
        _mint(to, amount);
    }

    function grantOperator(address account) external virtual {
        _grantOperator(account);
    }

    function setTokenMetadataURI(
        uint256 tokenId,
        string memory metadata
    ) external {
        _setTokenMetadataURI(tokenId, metadata);
    }

    function setBaseURI(string memory metadata) external virtual {
        _setBaseURI(metadata);
    }
}
