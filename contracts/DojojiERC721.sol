// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/utils/Base64.sol";
import "./ERC721A/IErc721BurningErc20OnMint.sol";
import "./utils/DojojiUtils.sol";
import "./utils/ReentrancyGuard.sol";
import "./ERC721A/ERC721A.sol";
import "./ERC5050/ERC5050.sol";


pragma solidity ^0.8.15;

contract DojojiBell is ERC5050,Erc721BurningErc20OnMint, Ownable, ReentrancyGuard {


    string public universalCode = unicode'⛩️';
    using Strings for uint256;
    bool public TempleOpened = true;
    uint256 public bells = 3333;
    uint256 public _maxEnligthened = 333;
    uint256 public _enligthenedBells = 0;
    uint256 public MaxRing = 2;
    uint256 public bellsMintLimit = 1;
    bool public teamMinted = false;
    bool public openERC20 = false;

    uint256 public _totalRings = 0;
    uint256 public _totalpray = 0;
    uint256 public _ringsToEnlight = 6;
    uint256 public _prayTime = 1 minutes;

    mapping(uint256 => uint256) public userTotalRings;
    mapping(address => uint256) public userTotalPrays;
    mapping(uint256 => uint256) public userPraySinceRing;
    mapping(address => bool) public claimStatuses;
    mapping(address => bool) public hasBell;
    mapping(address => uint256) public mintPray;
    mapping(address => uint256) public originalRinger;
    mapping(address => uint256) public prayCooldown;
    mapping(uint256 => bool) public _isEnlightened;
    mapping(address => bool) public _hasBurned;

    address dojojiERC20;
    bytes public constant DATA = hex'001011';
    bytes4 public constant RING_SELECTOR = bytes4(keccak256('ring'));
    bytes4 public constant PRAY_SELECTOR = bytes4(keccak256('pray'));
    bytes4 public constant CAST_SELECTOR = bytes4(keccak256('cast'));
    bytes4 public constant EAT_SHROOM_SELECTOR = bytes4(keccak256("eat_shroom"));
    mapping(address => bool) public _isAdmin;

    uint256 public FREN_PRICE = 0.0222 ether;
    uint256 public BELL_PRICE = 0.0333 ether;
    uint256 public ENGLIGHTENED_PRICE = 3.33 ether;

    uint256 public _burnReward = 100 ether;
    bool public _canMeltWithoutCast=false;

    Action public _ring;
    Action public _pray;
    Object public userfrom;
    Object public userto;
    string public _enlightenedURI;
    string public _tokenURI;
    event MushroomEaten(uint256 bellId);

    constructor(string memory _baseuri,string memory _enlighturi) ERC721A('Dojoji Bell', 'BELL') {
        _registerReceivable("pray");
        _registerReceivable("ring");
        _registerReceivable("cast");
         _registerReceivable("eat_shroom");
        _tokenURI=_baseuri;
        _enlightenedURI=_enlighturi;
    }

    address internal constant dojoji_grave =
        0x000000000000000000000000000000000000dEaD;
    address internal constant oxmon_address =
        0x3aaDA3e213aBf8529606924d8D1c55CbDc70Bf74;
    address internal constant goblintown_address =
        0xbCe3781ae7Ca1a5e050Bd9C4c77369867eBc307e;
    address internal constant saudis_address =
        0xe21EBCD28d37A67757B9Bc7b290f4C4928A430b1;
    address internal constant spells_address =
        0x7fef3f3364C7d8B9BFabB1b24D5CE92A402c6Bd3;
    address internal constant terrarium_address =
        0xC8d5517fd038206a65263Bc25B230F6809AC7E3a;
    address internal constant moonbirds_address =
        0x23581767a106ae21c074b2276D25e5C3e136a68b;
    address internal constant cryptopunks_address =
        0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB;
    address internal constant tsuka_address =
        0xc5fB36dd2fb59d3B98dEfF88425a3F425Ee469eD;
   address internal constant suzume_address =
        0x0B452278223D3954F4AC050949D7998e373e7E43;

    function _baseURI() internal view virtual override returns (string memory) {
        return _tokenURI;
    }

    function _enlightenmentURI() internal view virtual returns (string memory) {
        return _enlightenedURI;
    }

    function _isEligible(address user) public view returns (bool){
        if( IToken(goblintown_address).balanceOf(user) > 0 ||
                IToken(saudis_address).balanceOf(user) > 0 ||
                IToken(saudis_address).balanceOf(user) > 0 ||
                IToken(spells_address).balanceOf(user) > 0 ||
                IToken(oxmon_address).balanceOf(user) > 0 ||
                IToken(terrarium_address).balanceOf(user) > 0 ||
                IToken(moonbirds_address).balanceOf(user) > 0||
                IToken(cryptopunks_address).balanceOf(user) > 0||
                IToken(tsuka_address).balanceOf(user) > 0 ||
                IToken(suzume_address).balanceOf(user) > 0)
                return true;
                else
                return false;
    }

    function claimBell() external payable nonReentrant {
        uint256 bellId = totalSupply();
        require(TempleOpened, "The temple isn't opened");
        require(bellId < bells, 'No bells left...');
        require(msg.sender == tx.origin);
        require(!claimStatuses[msg.sender], 'Bell already claimed');
        require(_isEligible(msg.sender),"You don't own any of the collections"

        );
        require(
            msg.value >= FREN_PRICE,
            "pls attach 0.0222 ether per bell"
        );
        _safeMint(msg.sender, 1);
        _totalRings++;
        userTotalRings[bellId]++;
        hasBell[msg.sender] = true;
        originalRinger[msg.sender] = bellId;
        claimStatuses[msg.sender] = true;
    }

    //  🙏🏻🙏🙏🏻
    function mintBell() external payable nonReentrant mintConditions(1) {
        uint256 bellId = totalSupply();
        uint256 price = userMintPrice(msg.sender);
        require(TempleOpened, "The Quest for enlightment han't begun");
        require(!hasBell[msg.sender], 'User already has a Bell');
        require(
            msg.value >= price,
            unicode'Wow, pls attach more ether to mint bell'
        );
        _safeMint(msg.sender, 1);
        _totalRings++;
        userTotalRings[bellId]++;
        hasBell[msg.sender] = true;
        originalRinger[msg.sender] = bellId;
        userPraySinceRing[bellId]=userTotalPrays[msg.sender];
        userTotalPrays[msg.sender]=0;

        if (_totalRings >= MaxRing && !openERC20) {
            IDojoji(dojojiERC20).openDojoji();
            openERC20 = true;
        }
    }

    //
    function mintEnlightened() external payable nonReentrant {
        uint256 bellId = totalSupply();
        require(TempleOpened, "The Quest for enlightment han't begun");
        require(
            _maxEnligthened > 0,
            'The enligthened Ones have reached te maximum'
        );
        require(bellId < bells, 'No bells left...');
        require(msg.sender == tx.origin);
        require(
            msg.value >= ENGLIGHTENED_PRICE,
            unicode'ENGLIGHTENED Bells requiring 0.333 ether'
        );
        _safeMint(msg.sender, 1);
        _totalRings++;
        userTotalRings[bellId]++;
        _maxEnligthened -= 1;
        _enligthenedBells++;
        hasBell[msg.sender] = true;
        originalRinger[msg.sender] = bellId;
        _isEnlightened[bellId] = true;
    }

    function ringBell() external payable {
        userfrom = Object({
            _address: msg.sender,
            _tokenId: originalRinger[msg.sender]
        });
        userto = Object({
            _address: address(this),
            _tokenId: originalRinger[msg.sender]
        });

        _ring = Action({
            selector: RING_SELECTOR,
            user: msg.sender,
            from: userfrom,
            to: userto,
            state: address(this),
            data: DATA
        });

        _sendAction(_ring);
    }

    function pray() external payable {
        userfrom = Object({
            _address: msg.sender,
            _tokenId: originalRinger[msg.sender]
        });
        userto = Object({
            _address: address(this),
            _tokenId: originalRinger[msg.sender]
        });

        _pray = Action({
            selector: PRAY_SELECTOR,
            user: msg.sender,
            from: userfrom,
            to: userto,
            state: address(this),
            data: DATA
        });

        _sendAction(_pray);
    }

    function sendAction(Action memory action)
        external
        payable
        override
        onlySendableAction(action)
    {
        require(
            msg.sender == ownerOf(action.from._tokenId),
            'Spells: invalid sender'
        );
        _sendAction(action);
    }

    function _canRing(address _user) public view returns (bool) {
        uint256 tokenID = originalRinger[_user];
        if (userPraySinceRing[tokenID] > 2) return true;
        else return false;
    }

    function _canPray(address _user) public view returns (bool) {

        if (prayCooldown[_user] < block.timestamp) return true;
        else return false;
    }

    // 🔮
    function onActionReceived(Action calldata action, uint256 _nonce)
        external
        payable
        override
        onlyReceivableAction(action, _nonce)
    {
        require(
            action.selector == RING_SELECTOR ||
                action.selector == PRAY_SELECTOR,
            'Dojoji: invalid action.selector'
        );
        if (action.selector == RING_SELECTOR) {
            require(
                action.user == ownerOf(action.to._tokenId),
                'Dojoji: sender not owner of this bell'
            );

            require(_canRing(action.user), 'Sender must pray more');

            _totalRings++;
            userTotalRings[action.to._tokenId]++;
            userPraySinceRing[action.to._tokenId] -= 3;

            if (
                userTotalRings[action.to._tokenId] > _ringsToEnlight &&
                _maxEnligthened > 0
            ) {
                _isEnlightened[action.to._tokenId] = true;
                _maxEnligthened -= 1;
            }

            if (_totalRings >= MaxRing && !openERC20) {
                IDojoji(dojojiERC20).openDojoji();
                openERC20 = true;
            }
        }
        if (action.selector == PRAY_SELECTOR) {
            require(
                action.user == ownerOf(action.to._tokenId),
                'Dojoji: sender not owner of this bell'
            );
            require(_canPray(action.user), 'Must wait 3 hours before pray');

            userPraySinceRing[action.to._tokenId]++;
            userTotalPrays[action.user]++;
            _totalpray++;
            prayCooldown[action.user] = block.timestamp + _prayTime;
        }
        if (action.selector == CAST_SELECTOR) {
            require(
                action.user == ownerOf(action.to._tokenId),
                'Dojoji: sender not owner of this bell'
            );
            require(
                this.isEnlightened(action.user),
                'You must Ring and Pray more'
            );

            require(
                !_hasBurned[action.user],
                'You Have already melted your bell'
            );
            _burn(action.to._tokenId);
            _hasBurned[action.user] = true;

            require(
                IERC20(dojojiERC20).balanceOf(address(this)) > _burnReward,
                'No more $Dojoji to give'
            );
            IERC20(dojojiERC20).transfer(action.user, _burnReward);
        }

         if (action.selector == EAT_SHROOM_SELECTOR) {
             require(
                action.user == ownerOf(action.to._tokenId),
                'Dojoji: sender not owner of this bell'
            );
            _isEnlightened[action.to._tokenId] = true;


         }

    }
    function prayToMint() public nonReentrant{
        require(!openERC20,"You missed the beggining of the show");
        require(_canPray(msg.sender), "Must wait 6 hours before pray");
            mintPray[msg.sender]++;
            userTotalPrays[msg.sender]++;
            _totalpray++;
            prayCooldown[msg.sender] = block.timestamp + _prayTime;


    }
    function userMintPrice(address user)public view returns(uint256){
        uint256 mintprice = BELL_PRICE *(100-3*mintPray[user])/100;
        if(mintprice > FREN_PRICE)
        return mintprice;
        else
        return FREN_PRICE;

    }

    function meltBell() public nonReentrant {
        uint256 bellId = originalRinger[msg.sender];
        require(_canMeltWithoutCast,"you need to cast with spells to get your rewards");

        require(this.isEnlightened(msg.sender), 'You must Ring and Pray more');

        require(!_hasBurned[msg.sender], 'You Have already melted your bell');
        _burn(bellId);
        _hasBurned[msg.sender] = true;

        require(
            IERC20(dojojiERC20).balanceOf(address(this)) > _burnReward,
            'No more $Dojoji to give'
        );
        IERC20(dojojiERC20).transfer(msg.sender, _burnReward);
    }

    function isEnlightened(address user) external view returns (bool) {
        uint256 bellId = originalRinger[user];
        return _isEnlightened[bellId];
    }

    function broadcastEnlightenedMessage(
        uint256 bellId,
        string calldata message
    ) public {
        require(msg.sender == ownerOf(bellId), 'Mushrooms: sender not owner');
        require(_isEnlightened[bellId], "Bell isn't Enlightened");
        universalCode = message;
    }

    // 🔔
    function teamMinting(address _address, uint256 _bell) public onlyOwner {

        uint256 totalmushrooms = totalSupply();
        require(totalmushrooms + _bell <= bells);
        _safeMint(_address, _bell);
        _totalRings = _totalRings + _bell;

    }

    function openTemple(bool _open) external onlyOwner {
        TempleOpened = _open;
    }

    function dojojifundus() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }('');
        require(success);
    }

    function somethingAboutTokens(address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, balance);
    }

    function setDojojiAddress(address _dojoji) external onlyOwner {
        dojojiERC20 = _dojoji;
    }

    function setBaseUri(string memory uri) external onlyOwner {
        _tokenURI = uri;
    }

    function setEnlightenedUri(string memory uri) external onlyOwner {
        _enlightenedURI = uri;
    }

    function updateprayTime(uint256 praytime) external onlyOwner {
        _prayTime = praytime;
    }

    function updateRingsToEnlight(uint256 ringsToEnlight) external onlyOwner {
        _ringsToEnlight = ringsToEnlight;
    }

    function updatePrices(
        uint256 _frenPrice,
        uint256 _bellPrice,
        uint256 _enlightenedPrice
    ) external onlyOwner {
        FREN_PRICE = _frenPrice;
        BELL_PRICE = _bellPrice;
        ENGLIGHTENED_PRICE = _enlightenedPrice;
    }
   function setMelt(bool canMelt) external onlyOwner {
       _canMeltWithoutCast = canMelt;
    }
    function setAdmin(address _dojoji) external onlyOwner {
        _isAdmin[_dojoji] = true;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        string memory url;
        if (_isEnlightened[tokenId]) {
            url = _enlightenmentURI();
        } else {
            url = _baseURI();
        }

        return url;
    }

    modifier mintConditions(uint256 _bell) {
        require(TempleOpened, 'Patience is key');
        require(totalSupply() + _bell <= bells, 'No bells left...');
        require(
            tx.origin == msg.sender,
            unicode'no bots and shady automations'
        );
        _;
    }
    modifier onlyAdmins() {
        require(
            owner() == _msgSender() || _isAdmin[_msgSender()],
            'Ownable: caller is not the owner'
        );
        _;
    }
}

