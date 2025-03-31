// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/Doge.sol";

import { console } from "forge-std/console.sol";
import "forge-std/Vm.sol";


contract TestDoge is Test {
    Doge d;
    
    function setUp() public {
        string memory tokenURI = "";
        d= new Doge(tokenURI);
    }

    function testMint() public {
        d.mint(address(this),100);
        assertEq(d.balanceOf(address(this)),100);

    }


    function testBurn() public {
        d.mint(address(this),100);
        d.burn(address(this),100);
        assertEq(d.balanceOf(address(this)),0);
    }


}