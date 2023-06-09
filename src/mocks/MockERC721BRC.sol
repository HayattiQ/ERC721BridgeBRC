// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import {ERC721BRC} from "../ERC721BRC.sol";
import {ERC721, IERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract MockERC721BRC is ERC721BRC, ERC721 {
    constructor(
        IERC721 _underlyingToken,
        address _bridgeContract
    )
        ERC721BRC(_underlyingToken, _bridgeContract)
        ERC721("MockBTC", "MOCKBTC")
    {}

    function mint(address to, uint256 tokenId) external virtual {
        _mint(to, tokenId);
    }
}
