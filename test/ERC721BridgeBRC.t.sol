// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {MockERC721BridgeBRC} from "../src/mocks/MockERC721BridgeBRC.sol";
import {MockERC721} from "../src/mocks/MockERC721.sol";

contract ERC721BridgeBRCTest is Test {
    MockERC721BridgeBRC public nft;
    MockERC721 public original;

    address public bob;
    address public alis;

    function setUp() public {
        bob = makeAddr("bob");
        vm.deal(bob, 1 ether);
        alis = makeAddr("alis");
        vm.deal(alis, 1 ether);
        original = new MockERC721();
        nft = new MockERC721BridgeBRC(address(original));
    }

    function testMint() public {
        nft.grantOperator(bob);
        original.mint(bob, 1);
        original.mint(bob, 2);
        original.mint(bob, 3);
        vm.prank(bob);
        original.safeTransferFrom(bob, address(nft), 1);
        vm.prank(bob);
        original.safeTransferFrom(bob, address(nft), 2);

        assertEq(nft.hasOriginalNFT(1), true);
        assertEq(nft.hasOriginalNFT(2), true);
        assertEq(nft.hasOriginalNFT(3), false);
    }

    function testMintOperatorGranted() public {
        original.mint(bob, 1);
        original.mint(bob, 2);
        original.mint(alis, 3);
        vm.prank(bob);
        vm.expectRevert("token transfer need operator role");
        original.safeTransferFrom(bob, address(nft), 1);

        nft.grantOperator(bob);
        vm.prank(bob);
        original.safeTransferFrom(bob, address(nft), 1);

        vm.prank(alis);
        vm.expectRevert("token transfer need operator role");
        original.safeTransferFrom(alis, address(nft), 3);
    }

    function testMintTokenId() public {
        original.mint(bob, 3);
        original.mint(bob, 4);
        original.mint(alis, 5);
        original.mint(bob, 6);
        nft.grantOperator(bob);

        vm.startPrank(bob);
        original.safeTransferFrom(bob, address(nft), 4);
        original.safeTransferFrom(bob, address(nft), 3);
        nft.mint(bob, 1);
        nft.mint(bob, 2);
        assertEq(nft.originalTokenId(1), 4);
        assertEq(nft.originalTokenId(2), 3);

        // transferFrom don't count
        vm.startPrank(alis);
        original.transferFrom(alis, address(nft), 5);
        nft.mint(alis, 3);
        assertEq(nft.originalTokenId(3), 0);

        // Ignore alis transfer
        vm.startPrank(bob);
        original.safeTransferFrom(bob, address(nft), 6);
        assertEq(nft.originalTokenId(3), 6);
    }
}
