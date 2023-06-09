// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

abstract contract ERC721BRC {
    IERC721 private immutable _underlying;

    event TokenDeposit(address indexed from, uint256 tokenId);

    address public bridgeContract;
    mapping(address => bool) private _operator;

    constructor(IERC721 underlyingToken, address _bridgeContract) {
        _underlying = underlyingToken;
        _registBridgeContractAddress(_bridgeContract);
    }

    function _registBridgeContractAddress(address _contract) internal {
        bridgeContract = _contract;
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

    function depositSupply() public view returns (uint256) {
        return _underlying.balanceOf(address(this));
    }

    // This is an "unsafe" transfer that doesn't call any hook on the receiver. With underlying() being trusted
    // (by design of this contract) and no other contracts expected to be called from there, we are safe.
    // slither-disable-next-line reentrancy-no-eth
    function deposit(uint256 _tokenId) public virtual {
        _underlying.transferFrom(msg.sender, address(this), _tokenId);
        emit TokenDeposit(msg.sender, _tokenId);
    }
}
