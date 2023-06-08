// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import {ERC721BridgeBRC} from "../ERC721BridgeBRC.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract ERC721BridgeBRCTokenURL is ERC721BridgeBRC {
    using Strings for uint256;
    /// @dev This event emits when the metadata of a token is changed.
    /// So that the third-party platforms such as NFT market could
    /// timely update the images and related attributes of the NFT.
    event MetadataUpdate(uint256 _tokenId);

    /// @dev This event emits when the metadata of a range of tokens is changed.
    /// So that the third-party platforms such as NFT market could
    /// timely update the images and related attributes of the NFTs.
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);

    string private _baseMetadataURI = "";
    mapping(uint256 => string) private _metadataURI;
    string private constant _BASE_EXTENSION = ".json";

    constructor(
        string memory _name,
        string memory _symbol,
        IERC721 _underlyingToken,
        address _bridgeContract
    )
        ERC721BridgeBRC(_underlyingToken, _bridgeContract)
        ERC721(_name, _symbol)
    {}

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert("This token has not minted");
        if (bytes(_metadataURI[tokenId]).length != 0) {
            return _metadataURI[tokenId];
        } else {
            return
                string(
                    abi.encodePacked(
                        _baseMetadataURI,
                        tokenId.toString(),
                        _BASE_EXTENSION
                    )
                );
        }
    }

    function _setTokenMetadataURI(
        uint256 tokenId,
        string memory metadata
    ) internal virtual {
        _metadataURI[tokenId] = metadata;
        emit MetadataUpdate(tokenId);
    }

    function _setBaseURI(
        string memory metadata,
        uint256 _max_range
    ) internal virtual {
        _baseMetadataURI = metadata;
        emit BatchMetadataUpdate(1, _max_range);
    }
}
