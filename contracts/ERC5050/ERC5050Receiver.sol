// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "./ERC5050Sender.sol";
/**********************************************************\
* Author: alxi <chitch@alxi.nl> (https://twitter.com/0xalxi)
* EIP-5050 Token Interaction Standard: [tbd]
*
* Implementation of an interactive token protocol.
/**********************************************************/

contract ERC5050Receiver is Controllable, IERC5050Receiver {
    using Address for address;
    using ActionsSet for ActionsSet.Set;

    ActionsSet.Set _receivableActions;

    modifier onlyReceivableAction(Action calldata action, uint256 nonce) {
        if (_isApprovedController(msg.sender, action.selector)) {
            return;
        }
        require(
            action.to._address == address(this),
            'ERC5050: invalid receiver'
        );
        require(
            _receivableActions.contains(action.selector),
            'ERC5050: invalid action'
        );
        require(
            action.from._address == address(0) ||
                action.from._address == msg.sender,
            'ERC5050: invalid sender'
        );
        require(
            (action.from._address != address(0) && action.user == tx.origin) ||
                action.user == msg.sender,
            'ERC5050: invalid sender'
        );
        _;
    }

    function receivableActions() external view returns (string[] memory) {
        return _receivableActions.names();
    }

    function onActionReceived(Action calldata action, uint256 nonce)
        external
        payable
        virtual
        override
        onlyReceivableAction(action, nonce)
    {
        _onActionReceived(action, nonce);
    }

    function _onActionReceived(Action calldata action, uint256 nonce)
        internal
        virtual
    {
        if (!_isApprovedController(msg.sender, action.selector)) {
            if (action.state != address(0)) {
                require(action.state.isContract(), 'ERC5050: invalid state');
                try
                    IERC5050Receiver(action.state).onActionReceived{
                        value: msg.value
                    }(action, nonce)
                {} catch (bytes memory reason) {
                    if (reason.length == 0) {
                        revert('ERC5050: call to non ERC5050Receiver');
                    } else {
                        revert('Error 432');
                    }
                }
            }
        }
        emit ActionReceived(
            action.selector,
            action.user,
            action.from._address,
            action.from._tokenId,
            action.to._address,
            action.to._tokenId,
            action.state,
            action.data
        );
    }

    function _registerReceivable(string memory action) internal {
        _receivableActions.add(action);
    }
}
