// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;


import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


contract BridgeETH is Ownable,ReentrancyGuard{
    address public DogeAddress;

    event Locked(address indexed from , uint256 amount);

    mapping (address => uint256) public pendingBalance;

    constructor(address _DogeAddress) Ownable(msg.sender){
        DogeAddress = _DogeAddress;
    }

    function lock(IERC20 _DogeAddress ,uint256 _amount) public nonReentrant {
        require(address(_DogeAddress) == DogeAddress, "Invalid Doge Address");
        require(_DogeAddress.allowance(msg.sender,address(this))>= _amount, "Insufficient Allowance");
        require(_DogeAddress.transferFrom(msg.sender, address(this), _amount), "Transfer Failed");
        emit Locked(msg.sender, _amount);
    }

    function unlock(IERC20 _DogeAddress , uint256 _amount) public nonReentrant {
        require(address(_DogeAddress) == DogeAddress, "Invalid Doge Address");
        require(pendingBalance[msg.sender] >= _amount, "Insufficient Balance");
        pendingBalance[msg.sender] -= _amount;
        _DogeAddress.transfer(msg.sender, _amount);
    }

    function burnedOnOppositeChain(address userAccount , uint256 _amount) public onlyOwner{ 
        pendingBalance[userAccount] += _amount;
    }

    function getPendingBalance(address _user) public view returns(uint256){
        return pendingBalance[_user];
    }

    function getContractBalance() public onlyOwner view returns(uint256){
        return IERC20(DogeAddress).balanceOf(address(this));
    }


}