// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {MockERC721BridgeBRC} from "../src/mocks/MockERC721BridgeBRC.sol";
import {MockERC721} from "../src/mocks/MockERC721.sol";
import "openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";

contract ERC721BridgeBRCTest is Test {
    using EnumerableSet for EnumerableSet.UintSet;

    EnumerableSet.UintSet private _tokenIds;
    MockERC721BridgeBRC public nft;
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
        nft = new MockERC721BridgeBRC(original, _bridge);
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

    function testMintAt() public {
        vm.startPrank(bob);
        original.setApprovalForAll(address(nft), true);
        original.mint(bob, 3);
        original.mint(bob, 4);
        original.mint(bob, 5);
        original.mint(bob, 6);
        original.mint(bob, 7);
        original.mint(bob, 9);
        original.mint(bob, 11);
        original.mint(bob, 19);

        nft.deposit(7);
        nft.deposit(5);
        nft.deposit(19);
        nft.deposit(11);

        // check deposited ids
        uint256[] memory values = new uint256[](4);
        values[0] = uint256(7);
        values[1] = uint256(5);
        values[2] = uint256(19);
        values[3] = uint256(11);
        assertEq(nft.depositTokenIds(), values);
        _tokenIds.add(5);
        _tokenIds.add(7);
        _tokenIds.add(11);
        _tokenIds.add(19);
        assertEq(_tokenIds.length(), 4);

        vm.recordLogs();

        // mint first
        nft.depositTokenIds();
        nft.mintAt(bob);
        Vm.Log[] memory entries = vm.getRecordedLogs();
        uint256 firstMintId = uint256(entries[0].topics[3]);
        assertEq(nft.ownerOf(firstMintId), bob);
        assertEq(_tokenIds.contains(firstMintId), true);
        _tokenIds.remove(firstMintId);
        assertEq(_tokenIds.length(), 3);

        // mint second
        nft.depositTokenIds();
        nft.mintAt(bob);
        entries = vm.getRecordedLogs();
        uint256 secondMintId = uint256(entries[0].topics[3]);
        assertEq(nft.ownerOf(secondMintId), bob);
        assertEq(_tokenIds.contains(secondMintId), true);
        _tokenIds.remove(secondMintId);
        assertEq(_tokenIds.length(), 2);

        // mint third
        nft.depositTokenIds();
        nft.mintAt(bob);
        entries = vm.getRecordedLogs();
        uint256 thirdMintId = uint256(entries[0].topics[3]);
        assertEq(nft.ownerOf(thirdMintId), bob);
        assertEq(_tokenIds.contains(thirdMintId), true);
        _tokenIds.remove(thirdMintId);
        assertEq(_tokenIds.length(), 1);

        // mint forth
        nft.depositTokenIds();
        nft.mintAt(bob);
        entries = vm.getRecordedLogs();
        uint256 forthMintId = uint256(entries[0].topics[3]);
        assertEq(nft.ownerOf(forthMintId), bob);
        assertEq(_tokenIds.contains(forthMintId), true);
        _tokenIds.remove(forthMintId);
        assertEq(_tokenIds.length(), 0);

        assertEq(nft.depositTokenIds(), new uint256[](0));
        vm.expectRevert("No values in the set");
        nft.mintAt(bob);

        assertEq(nft.ownerOf(5), bob);
        assertEq(nft.ownerOf(7), bob);
        assertEq(nft.ownerOf(11), bob);
        assertEq(nft.ownerOf(19), bob);
        assertEq(nft.balanceOf(bob), 4);

        vm.stopPrank();
    }

    function testBridge() public {
        string
            memory _nftAAddress = "bc1pdqhstcpkfte5h3k6sfxuh7t5s4yhxmznedt3kfdhtwg3h63x5g8sflwtqm";
        bytes
            memory _hex = hex"62633170647168737463706b6674653568336b36736678756837743573347968786d7a6e656474336b666468747767336836337835673873666c7774716d";
        assertEq(bytes(_nftAAddress), _hex);

        vm.startPrank(bob);

        original.mint(bob, 19);
        original.setApprovalForAll(address(nft), true);
        nft.deposit(19);
        nft.mintAt(bob);

        vm.expectRevert("ERC721: invalid token ID");
        nft.bridge(
            bob,
            1,
            "bc1pdqhstcpkfte5h3k6sfxuh7t5s4yhxmznedt3kfdhtwg3h63x5g8sflwtqm"
        );

        nft.bridge(
            bob,
            19,
            "bc1pdqhstcpkfte5h3k6sfxuh7t5s4yhxmznedt3kfdhtwg3h63x5g8sflwtqm"
        );
    }
}
