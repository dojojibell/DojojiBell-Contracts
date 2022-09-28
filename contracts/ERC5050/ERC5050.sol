// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "./ERC5050Receiver.sol";
/**********************************************************\
* Author: alxi <chitch@alxi.nl> (https://twitter.com/0xalxi)
* EIP-5050 Token Interaction Standard: [tbd]
*
* Implementation of an interactive token protocol.
/**********************************************************/

contract ERC5050 is ERC5050Sender, ERC5050Receiver {
    function _registerAction(string memory action) internal {
        _registerReceivable(action);
        _registerSendable(action);
    }
}
