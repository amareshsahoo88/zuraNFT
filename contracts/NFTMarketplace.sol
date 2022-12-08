//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// importing hardhat and openzeppelin 
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// 

contract NFTMarketplace is ERC721URIStorage {

// Declaring the state variables 
    address payable owner;
    Counters.Counter private _tokenIds;     // counter for number of tokens minted
    Counters.Counter private _itemSold;     // counter for number of NFT sold

    uint256 listPrice = 0.01 ether;         // initial minting list price

//assigning the address msg.sender to the state variable owner and pre defining the NFT name and ticker
    constructor() ERC721("HackNFT","ZURA"){
        owner = payable(msg.sender);
    }

// Declaring the structure for the attributes of the listed token
    struct ListedToken {
        uint tokenId;
        address payable owner;
        address payable seller;
        uint256 price;
        bool currentlyListed;
    }
// mapping the tokenid to the NFTs in the structure

    mapping(uint256 => ListedToken) private idToListedToken;

//this is a function that can be used in future to update or increase the initial minting price 

    function updateListPrice(uint256 _listPrice) public payable {
        require(owner==msg.sender , "Only owner can update the listing price");
        listPrice = _listPrice;
    }

// this is a function that returns the current listing price for an NFT

    function getListprice() public view returns (uint256) {
        return listPrice;
    }

//fetch the latest tokenId that has been generated using the current token id

    function getlatestIdToListedToken() public view returns(ListedToken memory) {
        uint256 currentTokenId = _tokenIds.current();
        return idToListedToken[currentTokenId];
    }

// using the token id fetch the NFT linked to the token id - helpful to retrieve deta 
// from the frontend for a particular NFT

    function getListedForTokenId(uint256 tokenId) public view returns(ListedToken memory) {
        return idToListedToken[tokenId];
    }

//  getting the current tokenId so that to be used for minting a new NFT

    function getCurrentToken() public view returns(uint256){
        return _tokenIds.current();
    }

//  this is the token creation function . --> tokenURI and initial minting price is given
//  initial checks of the incoming ether for minting is done
//  token id is incremented
//  safemint function is used to mint the NFT

    function createToken(string memory tokenURI, uint256 price) public payable returns(uint){
        require(msg.value == listPrice , "Send enough ether to list");
        require(price>0 , "Make sure your price isn't negetive");

        _tokenIds.increment();
        uint256 currentTokenId = _tokenIds.current();
        _safeMint(msg.sender,currentTokenId);

        _setTokenURI(currentTokenId,tokenURI);

        createListedToken(currentTokenId, price);

        return currentTokenId;

    }

//  it is creating the listed token object . it updates the data in the struct which is accessed through mapping.

    function createListedToken(uint256 tokenId, uint256 price) private {
        idToListedToken[tokenId] = ListedToken(
            tokenId,
            payable(address(this)),
            payable(msg.sender),
            price,
            true
        );
        _transfer(msg.sender, address(this),tokenId);
    }

//  This function shall be used by the frontend to retrieve all the NFT to be shownwhen it is requested

    function getAllNFTs() public view returns(ListedToken[] memory){
        uint nftCount = _tokenIds.current();
        ListedToken[] memory tokens = new ListedToken[](nftCount);

        uint currentIndex = 0;

        for(uint i=0;i<nftCount;i++){

            uint currentId = i+1;
            ListedToken storage currentItem = idToListedToken[currentId];
            tokens[currentIndex] = currentItem;
            currentIndex += 1;
        }
        return tokens;
    }

//  This function shall be used by fetch all the NFT held by a particular address

    function getMyNFTs() public view returns(ListedToken[] memory){
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

//  this for loop shall find the number of NFT
        for(uint i = 0; i< totalItemCount; i++){
            if(idToListedToken[i+1].owner==msg.sender || idToListedToken[i+1].seller == msg.sender){
                itemCount +=1;
            }
        }

        ListedToken[] memory items = new ListedToken[](itemCount);

//  this shall list the NFT

        for(uint i=0 ; i< totalItemCount ; i++){
            if(idToListedToken[i+1].owner==msg.sender || idToListedToken[i+1].seller == msg.sender){
                uint currentId = i+1;
                ListedToken storage currentItem = idToListedToken[currentId];
                items[currentIndex] = currentItem ;
                currentIndex +=1;
            }
        }
        return items;
    }

//  This function shall execute the sale at the marketplace when the seller is not the smartcontract it is a 3rd person

    function executeSale(uint256 tokenId) public payable {
       uint price = idToListedToken[tokenId].price;
        require(msg.value == price , "please submit the asking price for the NFT in order to purchase");

        address seller = idToListedToken[tokenId].seller;

        idToListedToken[tokenId].currentlyListed = true;
        idToListedToken[tokenId].seller = payable(msg.sender);
        _itemSold.increment();

        _transfer(address(this), msg.sender , tokenId);

        approve(address(this) , tokenId);

        payable(owner).transfer(listPrice);
        payable(seller).transfer(msg.value);

    }


}