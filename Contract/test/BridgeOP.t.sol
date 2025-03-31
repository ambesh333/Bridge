// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {BridgeOP, IWDOGE} from "src/BridgeOP.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract TestWDoge is ERC20, Ownable, IWDOGE {
    constructor() ERC20("WDoge", "WDOGE") Ownable(msg.sender) {}

    function mint(address _to, uint256 amount) public override {
        _mint(_to, amount);
    }

    function burn(address _from, uint256 amount) public override {
        _burn(_from, amount);
    }
}

contract BridgeOPTest is Test {
    TestWDoge wdoge;
    BridgeOP bridge;
    address user = address(0x123);

    function setUp() public {
        wdoge = new TestWDoge();
        bridge = new BridgeOP(address(wdoge));
    }

    function testMintSuccess() public {
        uint256 pendingAmount = 100 ether;
        bridge.burnedOnOppositeChain(user, pendingAmount);
        assertEq(bridge.pendingBalance(user), pendingAmount);

        uint256 balanceBefore = wdoge.balanceOf(user);

        vm.prank(user);
        bridge.mint(IWDOGE(address(wdoge)), pendingAmount);

        assertEq(bridge.pendingBalance(user), 0);

        uint256 balanceAfter = wdoge.balanceOf(user);
        assertEq(balanceAfter, balanceBefore + pendingAmount);
    }

    function testBurnSuccess() public {
        uint256 amount = 50 ether;

        wdoge.mint(user, amount);
        assertEq(wdoge.balanceOf(user), amount);


        vm.prank(user);
        bridge.burn(IWDOGE(address(wdoge)), amount);

       
        assertEq(wdoge.balanceOf(user), 0);
    }

    function testInvalidWDogeAddressForMint() public {
        uint256 pendingAmount = 100 ether;
        bridge.burnedOnOppositeChain(user, pendingAmount);

        vm.prank(user);
        vm.expectRevert("Invalid Doge Address");
        bridge.mint(IWDOGE(address(0xDEADBEEF)), pendingAmount);
    }

    function testInvalidWDogeAddressForBurn() public {
        uint256 amount = 50 ether;

        wdoge.mint(user, amount);

        vm.prank(user);
        vm.expectRevert("Invalid Doge Address");
        bridge.burn(IWDOGE(address(0xDEADBEEF)), amount);
    }
}
