// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {SimpleERC721BridgeBRCA, ERC721A} from "../src/example/SimpleERC721BridgeBRCA.sol";
import {MockERC721} from "../src/mocks/MockERC721.sol";
import {IERC721A} from "ERC721A/IERC721A.sol";

contract ERC721BridgeBRCTest is Test {
    MockERC721 public original;
    SimpleERC721BridgeBRCA public nftA;

    address public bob;
    address public alis;

    function setUp() public {
        bob = makeAddr("bob");
        vm.deal(bob, 1 ether);
        alis = makeAddr("alis");
        vm.deal(alis, 1 ether);
        original = new MockERC721();
        nftA = new SimpleERC721BridgeBRCA(address(original));
    }

    function testBridge() public {
        string
            memory _nftAAddress = "bc1pdqhstcpkfte5h3k6sfxuh7t5s4yhxmznedt3kfdhtwg3h63x5g8sflwtqm";
        bytes
            memory _hex = hex"62633170647168737463706b6674653568336b36736678756837743573347968786d7a6e656474336b666468747767336836337835673873666c7774716d";
        assertEq(bytes(_nftAAddress), _hex);

        // non approval transfer prohibit
        nftA.mint(bob, 1);
        vm.expectRevert(IERC721A.TransferCallerNotOwnerNorApproved.selector);
        nftA.bridge(
            bob,
            1,
            "bc1pdqhstcpkfte5h3k6sfxuh7t5s4yhxmznedt3kfdhtwg3h63x5g8sflwtqm"
        );

        // other owner approve is prohibit
        nftA.setApprovalForAll(address(nftA), true);
        vm.expectRevert(IERC721A.TransferCallerNotOwnerNorApproved.selector);
        nftA.bridge(
            bob,
            1,
            "bc1pdqhstcpkfte5h3k6sfxuh7t5s4yhxmznedt3kfdhtwg3h63x5g8sflwtqm"
        );

        // setApprove
        vm.startPrank(bob);
        nftA.setApprovalForAll(address(nftA), true);
        nftA.bridge(
            bob,
            1,
            "bc1pdqhstcpkfte5h3k6sfxuh7t5s4yhxmznedt3kfdhtwg3h63x5g8sflwtqm"
        );
    }

    function testERC721ATokenURI() public {
        original.mint(bob, 3);
        original.mint(bob, 4);
        original.mint(alis, 5);
        original.mint(bob, 6);
        nftA.grantOperator(bob);

        // tokenURL set
        nftA.setBaseURI("ipfs://new/");

        vm.startPrank(bob);
        original.safeTransferFrom(bob, address(nftA), 4);
        original.safeTransferFrom(bob, address(nftA), 3);

        nftA.mint(bob, 4);
        assertEq(nftA.originalTokenId(1), 4);
        assertEq(nftA.originalTokenId(2), 3);

        // tokenURL check
        assertEq(nftA.tokenURI(1), "ipfs://new/4.json");
        assertEq(nftA.tokenURI(2), "ipfs://new/3.json");

        // Change tokenURI
        nftA.setTokenMetadataURI(1, "ipfs://changed/");
        assertEq(nftA.tokenURI(1), "ipfs://changed/");
        assertEq(nftA.tokenURI(2), "ipfs://new/3.json");
    }

    function testMoreTokenURI() public {
        for (uint256 i = 1; i <= 8; i++) {
            original.mint(bob, i);
        }
        nftA.grantOperator(bob);
        nftA.setBaseURI("ar://DO3K5VGKt20yIpJlDVe4T-ZENylKtdoh6R8WdiJKvmE/");
        vm.startPrank(bob);
        original.safeTransferFrom(bob, address(nftA), 2);
        original.safeTransferFrom(bob, address(nftA), 4);
        original.safeTransferFrom(bob, address(nftA), 8);
        original.safeTransferFrom(bob, address(nftA), 7);
        nftA.mint(bob, 2);
        vm.stopPrank();
        assertEq(nftA.originalTokenId(1), 2);
        assertEq(nftA.originalTokenId(2), 4);
        assertEq(nftA.originalTokenId(3), 8);
        assertEq(nftA.originalTokenId(4), 7);
        assertEq(
            nftA.tokenURI(1),
            "ar://DO3K5VGKt20yIpJlDVe4T-ZENylKtdoh6R8WdiJKvmE/2.json"
        );
        assertEq(
            nftA.tokenURI(2),
            "ar://DO3K5VGKt20yIpJlDVe4T-ZENylKtdoh6R8WdiJKvmE/4.json"
        );

        vm.expectRevert("This token has not minted");
        nftA.tokenURI(3);

        nftA.mint(bob, 1);
        assertEq(
            nftA.tokenURI(3),
            "ar://DO3K5VGKt20yIpJlDVe4T-ZENylKtdoh6R8WdiJKvmE/8.json"
        );

        nftA.mint(bob, 1);
        assertEq(
            nftA.tokenURI(4),
            "ar://DO3K5VGKt20yIpJlDVe4T-ZENylKtdoh6R8WdiJKvmE/7.json"
        );

        vm.expectRevert("This token has not minted");
        nftA.tokenURI(5);
    }
}
