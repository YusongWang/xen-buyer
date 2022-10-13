const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

function eth(value) {
  return utils.parseEther(value);
}

describe("Buyer", function () {
  let sender;
  let xen;
  let buyer;

  beforeEach(async () => {
    [sender] = await ethers.getSigners();
    const Math = await ethers.getContractFactory("Math");
    const math = await Math.deploy();


    const XENCryptoFac = await ethers.getContractFactory("XENCrypto",{
      libraries: {
        Math: math.address,
      },
    });
    xen = await XENCryptoFac.deploy();

    const Buyer = await ethers.getContractFactory("Buyer");
    buyer = await Buyer.deploy(sender.address,"1",xen.address);
    console.log(buyer.address);
  });

  it("buy success", async function () {
    const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
    const unlockTime = (await time.latest()) + ONE_YEAR_IN_SECS;
    let [sender,b] = await ethers.getSigners();
    //await buyer.connect(b).buyToken("10");
    
    await buyer.buyToken("10");
    console.log(await buyer.idTracker());
    await time.increaseTo(unlockTime);

    await buyer.claimToken("10");
    console.log(await buyer.idTracker());
    let balance = await xen.balanceOf(sender.address);
    console.log(balance);
    expect(balance.toString()).to.equal("749000000000000000000");    
  });


});
