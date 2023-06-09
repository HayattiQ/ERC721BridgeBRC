// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {MockERC721BRC} from "../src/mocks/MockERC721BRC.sol";
import {MockERC721} from "../src/mocks/MockERC721.sol";

contract ERC721BRCTest is Test {
    MockERC721BRC public nft;
    MockERC721 public original;

    address public bob;
    address public alis;

    function setUp() public {
        bob = makeAddr("bob");
        vm.deal(bob, 1 ether);
        alis = makeAddr("alis");
        vm.deal(alis, 1 ether);
        address _bridge = makeAddr("bridge");
        original = new MockERC721();
        nft = new MockERC721BRC(original, _bridge);
    }

    function testMint() public {
        vm.startPrank(bob);
        original.mint(bob, 1);
        original.mint(bob, 2);
        original.mint(bob, 3);
        original.setApprovalForAll(address(nft), true);
        nft.deposit(1);
        nft.deposit(2);

        assertEq(nft.hasOriginalNFT(1), true);
        assertEq(nft.hasOriginalNFT(2), true);
        assertEq(nft.hasOriginalNFT(3), false);
        vm.stopPrank();
    }

    function testMintApproved() public {
        vm.startPrank(bob);
        original.mint(bob, 1);
        original.mint(bob, 2);
        original.mint(alis, 3);
        original.setApprovalForAll(address(nft), true);
        vm.stopPrank();
        vm.startPrank(alis);
        vm.expectRevert();
        nft.deposit(1);
        vm.stopPrank();
    }
}
