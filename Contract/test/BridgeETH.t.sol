// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {BridgeETH} from "src/BridgeETH.sol";
import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20 {
    constructor() ERC20("TestToken", "TST") {
    }

    function mint(address _to, uint256 amount) public {
        _mint(_to, amount);
    }
}

contract TestBridgeETH is Test{
    TestToken token;
    BridgeETH bridge;

    address user = address(0x123);

    function setUp() public {
        token = new TestToken();
        token.mint(user, 1_000 ether);
        bridge = new BridgeETH(address(token));
    }

    function testLock() public {
        uint amount = 100 ether;
        vm.prank(user);
        token.approve(address(bridge), amount);

        vm.prank(user);
        bridge.lock(IERC20(address(token)), amount);

        uint256 balance = token.balanceOf(address(bridge));
        assertEq(balance, amount);
    }

    function testUnlock() public {
        uint256 lockAmount = 200 ether;
        uint256 pendingAmount = 150 ether;

        vm.prank(user);
        token.approve(address(bridge), lockAmount);
        vm.prank(user);
        bridge.lock(IERC20(address(token)), lockAmount);

        bridge.burnedOnOppositeChain(user, pendingAmount);

        uint256 pending = bridge.getPendingBalance(user);
        assertEq(pending, pendingAmount);

        uint256 userBalanceBefore = token.balanceOf(user);

        vm.prank(user);
        bridge.unlock(IERC20(address(token)), pendingAmount);

        uint256 userBalanceAfter = token.balanceOf(user);
        assertEq(userBalanceAfter, userBalanceBefore + pendingAmount);

        uint256 pendingAfter = bridge.getPendingBalance(user);
        assertEq(pendingAfter, 0);
    }

    function testBurnedOnOppositeChain() public {
        uint256 pendingAmount = 50 ether;

        bridge.burnedOnOppositeChain(user, pendingAmount);

        uint256 pending = bridge.getPendingBalance(user);
        assertEq(pending, pendingAmount);
    }

    function testGetContractBalance() public {
        uint256 amount = 300 ether;

        vm.prank(user);
        token.approve(address(bridge), amount);
        vm.prank(user);
        bridge.lock(IERC20(address(token)), amount);

        uint256 contractBalance = bridge.getContractBalance();
        assertEq(contractBalance, amount);
    }

}