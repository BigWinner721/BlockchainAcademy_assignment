// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

// import "hardhat/console.sol";

contract ArtistMe is
    Initializable,
    ERC721URIStorageUpgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    //libraries
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenIds;
    CountersUpgradeable.Counter private _itemsSold;

    //variables
    uint256 listingPrice;
    uint256 sharePercent;

    // constant
    uint256 public constant HAHA = 1;

    mapping(uint256 => MarketItem) private idToMarketItem;

    //user attribute
    mapping(address => address) public parent;
    mapping(address => uint256) public credit;
    mapping(address => bool) public regstate;

    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    //events
    event MarketItemCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __ERC721_init("Arist Me Token", "AMT");
        __ERC721URIStorage_init();
        __Ownable_init();
        __UUPSUpgradeable_init();

        listingPrice = 0 ether;
        sharePercent = 50;
        regstate[address(0)] = true;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    /* Updates the listing price of the contract */
    function updateListingPrice(uint _listingPrice) public payable onlyOwner {
        listingPrice = _listingPrice;
    }

    /* Returns the listing price of the contract */
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    //
    function createToken(
        string memory tokenURI,
        address _parent
    ) public returns (uint) {
        require(regstate[_parent] == true, "parent shold be registered!");
        if (regstate[msg.sender] == false) {
            parent[msg.sender] = _parent;
        }
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        return newTokenId;
    }

    /* Mints a token and lists it in the marketplace */
    function createTokenAndList(
        string memory tokenURI,
        uint256 price,
        address _parent
    ) public payable returns (uint) {
        require(regstate[_parent] == true, "parent shold be registered!");
        if (regstate[msg.sender] == false) {
            parent[msg.sender] = _parent;
        }
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        createMarketItem(newTokenId, price);
        return newTokenId;
    }

    function createMarketItem(uint256 tokenId, uint256 price) private {
        require(price > 0, "Price must be at least 1 wei");
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );

        idToMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );

        _transfer(msg.sender, address(this), tokenId);
        emit MarketItemCreated(
            tokenId,
            msg.sender,
            address(this),
            price,
            false
        );
    }

    /* allows someone to resell a token they have purchased */
    function resellToken(uint256 tokenId, uint256 price) public payable {
        require(
            idToMarketItem[tokenId].owner == msg.sender,
            "Only item owner can perform this operation"
        );
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );
        idToMarketItem[tokenId].sold = false;
        idToMarketItem[tokenId].price = price;
        idToMarketItem[tokenId].seller = payable(msg.sender);
        idToMarketItem[tokenId].owner = payable(address(this));
        _itemsSold.decrement();

        _transfer(msg.sender, address(this), tokenId);
    }

    /* Creates the sale of a marketplace item */
    /* Transfers ownership of the item, as well as funds between parties */
    function createMarketSale(uint256 tokenId) public payable {
        uint price = idToMarketItem[tokenId].price;
        address seller = idToMarketItem[tokenId].seller;
        require(
            msg.value == price,
            "Please submit the asking price in order to complete the purchase"
        );
        idToMarketItem[tokenId].owner = payable(msg.sender);
        idToMarketItem[tokenId].sold = true;
        idToMarketItem[tokenId].seller = payable(address(0));
        _itemsSold.increment();
        _transfer(address(this), msg.sender, tokenId);
        payable(owner()).transfer(listingPrice);
        payable(seller).transfer(msg.value);
    }

    /* Returns all unsold market items */
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint itemCount = _tokenIds.current();
        uint unsoldItemCount = _tokenIds.current() - _itemsSold.current();
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(this)) {
                uint currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /* Returns only items that a user has purchased */
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /* Returns only items a user has listed */
    function fetchItemsListed() public view returns (MarketItem[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                uint currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function upgradeTimes() public pure returns (uint256) {
        return 0;
    }
}
