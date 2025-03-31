// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Doge is ERC20,Ownable {
    string public tokenURI;

    constructor(string memory _uri) ERC20("Doge", "DOGE") Ownable(msg.sender){
        tokenURI = _uri;
    }

    function mint(address _to, uint256 amount) public onlyOwner {
        _mint(_to, amount);
    }

    function burn(address _from, uint256 amount) public onlyOwner {
        _burn(_from, amount);
    }

}

