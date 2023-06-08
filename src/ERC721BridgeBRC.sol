// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

abstract contract ERC721BridgeBRC is ERC721 {
    using EnumerableSet for EnumerableSet.UintSet;

    EnumerableSet.UintSet private _depositTokenId;
    IERC721 private immutable _underlying;

    event TokenDeposit(address indexed from, uint256 tokenId, bool added);

    address public bridgeContract;
    mapping(address => bool) private _operator;

    constructor(IERC721 underlyingToken, address _bridgeContract) {
        _underlying = underlyingToken;
        _registBridgeContractAddress(_bridgeContract);
    }

    function _registBridgeContractAddress(address _contract) internal {
        bridgeContract = _contract;
    }

    function bridge(
        address from,
        uint256 tokenId,
        string memory _btcAddress
    ) public virtual {
        safeTransferFrom(from, bridgeContract, tokenId, bytes(_btcAddress));
    }

    /**
     * @dev Returns `true` if this contract has original NFT. Regist Original contract to call this function.
     */
    function hasOriginalNFT(
        uint256 originalTokenId
    ) public view virtual returns (bool) {
        return _underlying.ownerOf(originalTokenId) == address(this);
    }

    function _emergencyWithdraw(address to, uint256 tokenId) internal virtual {
        _underlying.transferFrom(address(this), to, tokenId);
    }

    function depositedTokenIds() public view returns (uint256[] memory) {
        return _depositTokenId.values();
    }

    function _mintAt(address _to) internal virtual {
        require(_depositTokenId.length() > 0, "No values in the set");
        uint256 _tokenId = _depositTokenId.at(0);
        require(
            _depositTokenId.remove(_tokenId),
            "Failed to remove the value from the depositId"
        );
        _mint(_to, _tokenId);
    }

    // This is an "unsafe" transfer that doesn't call any hook on the receiver. With underlying() being trusted
    // (by design of this contract) and no other contracts expected to be called from there, we are safe.
    // slither-disable-next-line reentrancy-no-eth
    function deposit(uint256 _tokenId) public virtual {
        _underlying.transferFrom(msg.sender, address(this), _tokenId);
        bool added = _depositTokenId.add(_tokenId);
        emit TokenDeposit(msg.sender, _tokenId, added);
    }
}
