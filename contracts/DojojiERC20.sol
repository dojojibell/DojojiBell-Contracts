// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IDojojiNFT {
    function balanceOf(address) external view returns(uint256);
    function isEnlightened(address) external view returns(bool);
}


interface IUniV3 {
    function balanceOf(address) external view returns(uint256);
    function approve(address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}


contract Dojoji is ERC20, IERC721Receiver, Ownable, ReentrancyGuard {
    address dojoji_NFT;
    address meditationRewardsAddress;
    address UniV3LP;
    uint256 UniV3ID;
    bytes UniV3data;
    bool isLocked;
    uint256 internal OpenBlock;

    uint256 MAX_TOTAL_SUPPLY = 108 * 10 ** 6 * 10 ** 18;
    uint256 meditationFee = 3;
    uint256 burnFee = 6;
    uint256 baseFee = burnFee + meditationFee;
    uint256 holderFee = 3;
    uint256 enlightenedFee = 0;
    bool _openDojoji = false;

    mapping(address => bool) public isBot;
    uint256 univ3LockTime;

    constructor(address _meditationRewardsAddress, address _dojoji_nft) ERC20("Dojoji", "DOJOJI") {
        meditationRewardsAddress = _meditationRewardsAddress;
        dojoji_NFT = _dojoji_nft;

        _mint(owner(), MAX_TOTAL_SUPPLY);

    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public override returns(bytes4) {
        require(operator != address(0), "Dojoji UniswapV3 ::onERC721Received: not a univ3 nft");
        require(from == owner(), "Only Owner can send UniswapV3 Position");
        UniV3ID = tokenId;
        UniV3data = data;

        return this.onERC721Received.selector;
    }

    function transfer(address to, uint256 amount) public virtual override returns(bool) {
        address sender = msg.sender;
        uint dojojiFee;

        if (msg.sender != owner()) {
            require(_openDojoji, "The Bell has to ring more");
            require(!isBot[sender] && !isBot[to], "no non frens allowed");
            if (block.timestamp < OpenBlock) isBot[msg.sender] = true;

            if (IDojojiNFT(dojoji_NFT).balanceOf(msg.sender) > 0) {
                if (IDojojiNFT(dojoji_NFT).isEnlightened(sender)) {
                    dojojiFee = 100 - enlightenedFee;
                } else {
                    dojojiFee = 100 - holderFee;
                }
            } else {
                dojojiFee = 100 - baseFee;
            }

            _burn(sender, (amount * 2 * (100 - dojojiFee)) / 300); // The burned amount is 2/3 of the fee
            _transfer(sender, meditationRewardsAddress, (amount * (100 - dojojiFee)) / 300); // The sent amount to be rewarded to enlightened bells is 1/3 of the fee
            _transfer(sender, to, (amount * dojojiFee) / 100);
        } else {
            _transfer(sender, to, amount);
        }

        return true;
    }

    function openDojoji() external nonReentrant returns(bool) {
        require(msg.sender == owner() || msg.sender == dojoji_NFT, "Not Dojoji Controller");
        _openDojoji = true;
        uint256 randomHour = 1 minutes;
        OpenBlock = block.timestamp + (uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender, block.difficulty))
        ) % randomHour);
        return _openDojoji;
    }

    function UniV3lock(uint256 tokenId) public nonReentrant onlyOwner {
        univ3LockTime = block.timestamp + 30 seconds;

        IUniV3(UniV3LP).safeTransferFrom(msg.sender, address(this), tokenId);

        isLocked = true;
    }

    function UniV3unlock(uint256 tokenId) public nonReentrant onlyOwner {
        require(univ3LockTime < block.timestamp, "Lock Period isn't over");
        IUniV3(UniV3LP).approve(msg.sender, tokenId);
        IUniV3(UniV3LP).safeTransferFrom(address(this), owner(), tokenId);
        isLocked = false;
    }

    function setUniV3Address(address _uniV3LP) public onlyOwner {
        UniV3LP = _uniV3LP;
    }

    function setmeditationRewardsAddress(address _meditationRewardsAddress) public onlyOwner {
        meditationRewardsAddress = _meditationRewardsAddress;
    }

    function setBurnFee(uint _burnFee) public onlyOwner {
        burnFee = _burnFee;
    }

    function setMeditationFee(uint _meditationFee) public onlyOwner {
        meditationFee = _meditationFee;
    }
    function setBots(address[] calldata _addresses, bool bot) public onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            isBot[_addresses[i]] = bot;
        }
    }

}
