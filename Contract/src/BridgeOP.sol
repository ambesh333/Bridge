// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWDOGE is IERC20{ 
    function mint(address _to, uint256 amount) external;
    function burn(address _from, uint256 amount) external;
}

contract BridgeOP is Ownable {
    address public WDogeAddress;

    event Locked(address indexed from , uint256 amount);

    mapping (address => uint256) public pendingBalance;

    event Burn(address indexed from , uint256 amount);

    constructor(address _WDogeAddress) Ownable(msg.sender){
        WDogeAddress = _WDogeAddress;
    }

    function mint(IWDOGE _WDogeAddress , uint256 _amount) public {
       require(address(_WDogeAddress) == WDogeAddress, "Invalid Doge Address");
       require(pendingBalance[msg.sender] >= _amount, "Insufficient Balance");
       pendingBalance[msg.sender] -= _amount;
       _WDogeAddress.mint(msg.sender, _amount);
    }

    function burn(IWDOGE _WDogeAddress , uint256 _amount) public{
        require(address(_WDogeAddress) == WDogeAddress, "Invalid Doge Address");
        _WDogeAddress.burn(msg.sender, _amount);
        emit Burn(msg.sender, _amount);
    }

    function burnedOnOppositeChain(address userAccount , uint256 _amount) public onlyOwner{ 
        pendingBalance[userAccount] += _amount;
    }
}