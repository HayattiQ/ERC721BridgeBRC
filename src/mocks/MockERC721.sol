// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract MockERC721 is ERC721 {
    constructor() ERC721("Mock", "MOCK") {}

    function mint(address to, uint256 tokenId) external virtual {
        _mint(to, tokenId);
    }
}
