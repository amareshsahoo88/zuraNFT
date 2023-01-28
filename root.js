const { MerkleTree } = require('merkletreejs')

const keccak256 = require('keccak256')
//const SHA256 = require('crypto-js/sha256')

const whitelistedAddresses = [
"0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC" ,
"0x90F79bf6EB2c4f870365E785982E1f101E93b906" ,
"0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65" ,
"0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc"
]

const leafNodes = whitelistedAddresses.map(addr=>keccak256(addr))

console.log("leafNodes:", leafNodes);

const merkleTree = new MerkleTree(leafNodes, keccak256, {sortPairs:true})

//const roothash = merkleTree.getRoot().toString('bytes');

//console.log(roothash);

console.log("---------");
console.log("Merke Tree");
console.log("---------");
console.log(merkleTree.toString());
console.log("---------");
console.log("Merkle Root: " + merkleTree.getHexRoot());

console.log("Proof 1: " + merkleTree.getHexProof(leafNodes[0]));
console.log("Proof 2: " + merkleTree.getHexProof(leafNodes[1]));
console.log("Proof 3: " + merkleTree.getHexProof(leafNodes[2]));
console.log("Proof 4: " + merkleTree.getHexProof(leafNodes[3]));



// 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
// 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
// 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC
// 0x90F79bf6EB2c4f870365E785982E1f101E93b906
// 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65
// 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc


// Merkle Root: 0xee068f44d79b0b5ec5c9fdce424d1cb399ed31b481f41d901b2d90447857ca89
// Proof 1: ["0x1ebaa930b8e9130423c183bf38b0564b0103180b7dad301013b18e59880541ae","0xa22d2d4af6076ff70babd4ffc5035bdce39be98f440f86a0ddc202e3cd935a59"]
// Proof 2: ["0x8a3552d60a98e0ade765adddad0a2e420ca9b1eef5f326ba7ab860bb4ea72c94","0xa22d2d4af6076ff70babd4ffc5035bdce39be98f440f86a0ddc202e3cd935a59"]
// Proof 3: ["0xe5c951f74bc89efa166514ac99d872f6b7a3c11aff63f51246c3742dfa925c9b","0x7e0eefeb2d8740528b8f598997a219669f0842302d3c573e9bb7262be3387e63"]
// Proof 4: ["0xf4ca8532861558e29f9858a3804245bb30f0303cc71e4192e41546237b6ce58b","0x7e0eefeb2d8740528b8f598997a219669f0842302d3c573e9bb7262be3387e63"]
