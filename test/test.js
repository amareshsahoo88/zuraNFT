const { expect, assert } = require("chai");
const { ethers } = require('hardhat')
const { BN, expectRevert, constants } = require('@openzeppelin/test-helpers');
require('chai').use(require('chai-as-promised')).should();



describe('ZuraNFT', function () {
    let ZuraNFTContract , ZuraNFT ,  owner, addr1, addr2, addr3, addr4 , addr5 ;
    

    function bn(x) {
      return new BN(BigInt(Math.round(parseFloat(x))))
  }

    beforeEach(async function () {
      ZuraNFT = await ethers.getContractFactory('ZuraNFT');
      [owner, addr1, addr2, addr3, addr4 , addr5] = await ethers.getSigners()
      ZuraNFTContract = await ZuraNFT.deploy(3 , "10000000000000000" , 10 , 3)
    })

   

    describe('Deployment', function () {
      it('Should set the right owner and correct constructor values', async function () {

        console.log(owner.address);
        console.log(addr1.address);
        console.log(addr2.address);
        console.log(addr3.address);
        console.log(addr4.address);
        console.log(addr5.address);

         console.log(ZuraNFTContract.owner);
        expect(await ZuraNFTContract.owner()).to.equal(owner.address)

        expect(await ZuraNFTContract.freeLimit()).to.equal(3)

       

       let listPrice1 = await ZuraNFTContract.listPrice()

      bn(listPrice1).should.be.bignumber.eq(bn("10000000000000000"))

       expect(await ZuraNFTContract.Max_Token()).to.equal(10)

        expect(await ZuraNFTContract.MINT_TRACKER()).to.equal(3)
      })
    })

    describe('allowMint function', function (){
      it('Should be reverted because the caller is not owner', async function(){
       await expect(
        ZuraNFTContract.connect(addr1).allowMinting(true),
        ).to.be.revertedWith('Ownable: caller is not the owner')
      })

      it('Should set the value of allowMint to true', async function(){
        const expectedValue = true

        await ZuraNFTContract.connect(owner).allowMinting(expectedValue)

        expect(await ZuraNFTContract.allowMint()).to.equal(expectedValue)

      })
    })

    describe('setMerkelRoot function', function (){
      it('Should be reverted because the caller is not owner', async function(){
       await expect(
        ZuraNFTContract.connect(addr1).setMerkleRoot("0xee068f44d79b0b5ec5c9fdce424d1cb399ed31b481f41d901b2d90447857ca89"),
        ).to.be.revertedWith('Ownable: caller is not the owner')
      })

      it('Should set the desired ', async function(){
        const expectedValue = "0xee068f44d79b0b5ec5c9fdce424d1cb399ed31b481f41d901b2d90447857ca89"

        await ZuraNFTContract.connect(owner).setMerkleRoot(expectedValue)

        expect(await ZuraNFTContract.getMerkleRoot()).to.equal(expectedValue)

      })
    })

    describe('minting process', function (){
      it('should mint upto 1st installment', async function (){
        ZuraNFTContract.connect(owner).setMerkleRoot("0xee068f44d79b0b5ec5c9fdce424d1cb399ed31b481f41d901b2d90447857ca89"),
        await ZuraNFTContract.freeMint(addr1 , "hello1" , ["0x1ebaa930b8e9130423c183bf38b0564b0103180b7dad301013b18e59880541ae","0xa22d2d4af6076ff70babd4ffc5035bdce39be98f440f86a0ddc202e3cd935a59"])
        expect(await ZuraNFTContract.balanceOf("0x70997970C51812dc3A010C7d01b50e0d17dc79C8")).to.equal(1);
        expect(await ZuraNFTContract._tokenIdCounter()).to.equal(1)
      })
    })

    // mint 3 times and check the allowmint function , mint with non whitelisted address , mint to expect revert coz of installment set..
    // mint normal mint in 2nd installement with less ether and expect revert , mint with 0.01 ether and expect mint
    // set max mint installement beyond the max mint limit and expect revert

    
})

