// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract ZuraNFT is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    Counters.Counter private _mintByInstallmentCounter;

    uint256 public MINT_TRACKER;

    uint256 public immutable Max_Token;   // Max supply

    uint256 public listPrice ;     //List price

    bool public allowMint;  

    uint public immutable freeLimit;

    bytes32 public merkleRoot ;  // root to be generated from a function            

    mapping(address => bool) public whitelistClaimed;

    constructor(uint _freeLimit , uint _listPrice , uint _maxToken , uint _MINT_TRACKER) ERC721("Hack NFT", "HACK") {
        freeLimit = _freeLimit;
        listPrice = _listPrice;
        Max_Token = _maxToken;
        MINT_TRACKER = _MINT_TRACKER;

    }

    function _baseURI() internal pure override returns (string memory) {
        return "infura";
    }

    // Getter function for Listing price 

    function getListprice() public view returns (uint256) {
        return listPrice;
    }

    function mintInstallemntcounter() public view returns(uint){
        return _mintByInstallmentCounter.current();
    }

    // Function for updating listing price

    function updateListPrice(uint256 _listPrice) public onlyOwner payable {
        listPrice = _listPrice;
    }

    // Function for re-allow minting after the installment is over

    function allowMinting(bool _allow) public onlyOwner{
        allowMint = _allow;
    }

   

    function getFreeLimit() public view returns(uint){
        return freeLimit;
    }

    // function to set the max number of NFT to be minted in a particular installment

    function setMaxMint(uint _maxMints) external onlyOwner {
        require(_maxMints>0, "0 maxMints");
        uint256 currentTokenId = _tokenIdCounter.current();
        require(currentTokenId + _maxMints <= Max_Token, "overflow TOTAL_SUPPLY");
        MINT_TRACKER = _maxMints;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function getMerkleRoot() external view returns(bytes32){
        return merkleRoot;
    }

    function freeMint(address to, string memory uri, bytes32[] calldata _merkleProof) public {
        require(!whitelistClaimed[msg.sender],"Address has already claimed.");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof , merkleRoot , leaf), "invalid proof.");

        whitelistClaimed[msg.sender] = true;

        //NFT_Mint(msg.sender);
        _mint(to, uri);

    }

    function _mint(address to, string memory uri) private {
       
        //_safeMint(to, currentTokenId);
        //_setTokenURI(currentTokenId, uri);
        //assert(currentTokenId <= Max_Token);

        require(allowMint == true, "Mint not allowed");
        _mintByInstallmentCounter.increment();
        uint256 currentMintByInstallmentCounter = _mintByInstallmentCounter.current();

         if(currentMintByInstallmentCounter == MINT_TRACKER) {
            _mintByInstallmentCounter.reset();
            allowMint = false;
            // revert("Mints disabled temporilly");
        }

          _tokenIdCounter.increment();
        uint256 currentTokenId = _tokenIdCounter.current();
        
        require(currentTokenId<= Max_Token,"maximum limit reached");

         _safeMint(to,currentTokenId);
         _setTokenURI(currentTokenId, uri);

    }





    function safeMint(string memory uri) external payable returns(uint) {
        
        uint256 currentTokenId = _tokenIdCounter.current();
        require(currentTokenId >= freeLimit, "After free mints"); // This function can be only called after 1k link
        
        require(msg.value >= listPrice , "Send enough ether to list");

         _mint(msg.sender, uri);
   
        return currentTokenId;
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}


// ["0x04a10bfd00977f54cc3450c9b25c9b3a502a089eba0097ba35fc33c4ea5fcb54","0xda2a605bdf59a3b18e24cd0b2d9110b6ffa2340f6f67bc48214ac70e49d12770"]

// ["0x999bf57501565dbd2fdcea36efa2b9aef8340a8901e3459f4a4c926275d36cdb","0xda2a605bdf59a3b18e24cd0b2d9110b6ffa2340f6f67bc48214ac70e49d12770"]

// ["0xf6d82c545c22b72034803633d3dda2b28e89fb704f3c111355ac43e10612aedc","0x39a01635c6a38f8beb0adde454f205fffbb2157797bf1980f8f93a5f70c9f8e6"]

// ["0xdfbe3e504ac4e35541bebad4d0e7574668e16fefa26cd4172f93e18b59ce9486","0x39a01635c6a38f8beb0adde454f205fffbb2157797bf1980f8f93a5f70c9f8e6"]

// 0xfbaa96a1f7806c1ab06f957c8fc6e60875b6880254f77b71439c7854a6b47755  - merkel root