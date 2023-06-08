// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import {ERC721BridgeBRC} from "../ERC721BridgeBRC.sol";
import {ERC721, IERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract MockERC721BridgeBRC is ERC721BridgeBRC {
    constructor(
        IERC721 _underlyingToken,
        address _bridgeContract
    )
        ERC721BridgeBRC(_underlyingToken, _bridgeContract)
        ERC721("MockBTC", "MOCKBTC")
    {}

    function mintAt(address to) external virtual {
        _mintAt(to);
    }
}
