// SPDX-License-Identifier: MIT
import "./ECDSA.sol";
import "./Ownable.sol";
import "./Payment.sol";
pragma solidity ^0.8.15;

interface IToken {
    function balanceOf(address) external view returns(uint256);
}


interface IDojoji {
    function openDojoji() external returns(bool);
}
